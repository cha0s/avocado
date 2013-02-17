
Box2D = require 'Physics/Box2D'
Entity = require 'Entity/Entity'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = Physics = class extends Trait
	
	@PixelsPerMeter = 13
	@world = null
	
	@createWorld: ->
	
		@world = new Box2D.b2World new Box2D.b2Vec2(0, 0), false
	
		contactListener = new Box2D.Dynamics.b2ContactListener()
		
		listeners = [
			
			# Entities
			begin: (l, r) ->
			end: (l, r) ->
		]
		
		contactListener.BeginContact = (contact) ->
			
			l = contact.GetFixtureA().GetBody().GetUserData()
			r = contact.GetFixtureB().GetBody().GetUserData()
			
			l.entity.emit 'collisionStart', l, r if l?.entity?
			r.entity.emit 'collisionStart', r, l if r?.entity?
			l.weapon.emit 'collisionStart', l, r if l?.weapon?
			r.weapon.emit 'collisionStart', r, l if r?.weapon?
			
		contactListener.EndContact = (contact) ->
			
			l = contact.GetFixtureA().GetBody().GetUserData()
			r = contact.GetFixtureB().GetBody().GetUserData()
			
			l.entity.emit 'collisionEnd', l, r if l?.entity?
			r.entity.emit 'collisionEnd', r, l if r?.entity?
			l.weapon.emit 'collisionEnd', l, r if l?.weapon?
			r.weapon.emit 'collisionEnd', r, l if r?.weapon?
			
		@world.SetContactListener contactListener
		
		contactFilter = new Box2D.Dynamics.b2ContactFilter()
		
		ShouldCollide = contactFilter.ShouldCollide
		
		contactFilter.ShouldCollide = (fixtureA, fixtureB) ->
			
			return false unless ShouldCollide.call this, fixtureA, fixtureB
			
			l = fixtureA.GetBody().GetUserData()
			r = fixtureB.GetBody().GetUserData()
			
			return true unless l? and r?
			
			return true unless l.entity is r.entity
			
			return false
			
		@world.SetContactFilter contactFilter
		
		@world
	
	defaults: ->
		
		bodyType: 'dynamic'
		solid: true
		radius: 4
		layer: 1
		floorFriction: .3
	
	translateBodyType = (type) ->
	
		switch type
			when 'dynamic' then Box2D.b2Body.b2_dynamicBody
			when 'static' then Box2D.b2Body.b2_staticBody

	adjustFilterBits: (filter, options) ->
	
		filter.categoryBits = 1 << options.layer
		
		filter.maskBits = if options.solid
			filter.categoryBits
		else
			0

	adjustFixtureFilterBits: (body, options) ->
	
		fixture = body.GetFixtureList()
		
		filter = fixture.GetFilterData()
		
		@adjustFilterBits filter, options
		
		fixture.SetFilterData filter
	
	constructor: (entity, state) ->
		super entity, state
		
		@isTouching = []
	
	createBody: (options) ->
		
		bodyDef = new Box2D.b2BodyDef()
		bodyDef.type = translateBodyType options.bodyType ? 'dynamic'
		bodyDef.fixedRotation = true
		
		body = Physics.world.CreateBody bodyDef
		
		circle = new Box2D.b2CircleShape()
		circle.SetRadius options.radius / Physics.PixelsPerMeter
		
		fixtureDef = new Box2D.b2FixtureDef()
		fixtureDef.shape = circle
		fixtureDef.density = options.density ? 0
		fixtureDef.friction = 0
		
		@adjustFilterBits fixtureDef.filter, options
		
		body.CreateFixture fixtureDef
		body.SetUserData entity: @entity
		
		body
	
	moveBody: (body, request, hypotenuse) ->
		
		request = Vector.copy request
	
		{x, y} = body.GetLinearVelocity()
		velocity = [x, -y]
		
		for i in [0..1]
			
			if request[i] > 0
				if velocity[i] >= hypotenuse[i]
					request[i] = 0
				else
					if (vr = velocity[i] + request[i]) > hypotenuse[i]
						request[i] = hypotenuse[i] - vr
				
			else if request[i] < 0
				if velocity[i] <= hypotenuse[i]
					request[i] = 0
				else
					if (vr = velocity[i] + request[i]) < hypotenuse[i]
						request[i] = hypotenuse[i] - vr
				
		body.ApplyImpulse(
			new Box2D.b2Vec2 request[0], -request[1]
			body.GetWorldCenter()
		)
	
	initializeTrait: (variables) ->
		
		return unless (@world = Physics.world)?
		
		@body = @createBody @state
		
		@resetTrait()
	
	translatePhysicsPosition: (position) ->
	
		Vector.toObject Vector.scale(
			position
			1 / Physics.PixelsPerMeter
		)
		
	resetTrait: ->
		
		@body.SetPosition @translatePhysicsPosition [
			@entity.x()
			-@entity.y()
		]
		
	removeTrait: ->
		
		return unless @world?
		
		@world.DestroyBody @body
	
	signals: ->
		
		positionChanged: ->
		
			@body.SetPosition @translatePhysicsPosition [
				@entity.x()
				-@entity.y()
			]
			
	actions: ->
		
		###
		
		setIsTouching: (entity) ->
			
			if -1 is @isTouching.indexOf entity
				
				@isTouching.push entity
				@entity.emit 'touched', entity
		
		unsetIsTouching: (entity) ->
			
			index = @isTouching.indexOf entity
			
			@isTouching.splice index, 1 unless index is -1
		
		###
		
		setMainPartyCollision: ->
			
			@adjustFixtureFilterBits @body, @state
			
		setRadius: (radius) -> @state.radius = radius
		
		setBodyType:
			
			f: (type) ->
			
				@body.SetType translateBodyType @state.bodyType = type
		
		setSolid:
			name: 'Set solidity'
			renderer: (candidate, args) ->
				
				'set ' + candidate + ' solidity to ' + Rule.Render args[0]
				
			f: (solid) ->
				
				@state.solid = solid
				
				@adjustFixtureFilterBits()
				
			argTypes: ['Boolean']
			argNames: ['Solidity']
		
		push: (hypotenuse) ->
		
			@body.ApplyImpulse(
				new Box2D.b2Vec2 hypotenuse[0], -hypotenuse[1]
				@body.GetWorldCenter()
			)
		
	values: ->
		
		isTouching:
			
			name: 'Is touching entity'
			renderer: (candidate, args) ->
				
				candidate + ' is touching ' + Rule.Render args[0]
				
			argTypes: ['Entity']
			argNames: ['Other entity']
			f: (entity) -> return -1 isnt @isTouching.indexOf entity
		
		radius: -> @state.radius
		
		isSolid: -> @state.solid
		
		touching: -> @isTouching
		
		bodyType: -> @state.bodyType
		
		world: -> @world
