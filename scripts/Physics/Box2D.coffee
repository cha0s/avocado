
{
	
	Box2D:
		
		Collision:
			Shapes:
				b2CircleShape: b2CircleShape
				b2PolygonShape: b2PolygonShape
				
		
		Common:
			Math:
				b2Vec2: b2Vec2
		
		Dynamics:
			b2BodyDef: b2BodyDef
			b2Body: b2Body
			b2ContactListener: b2ContactListener
			b2ContactFilter: b2ContactFilter
			b2FixtureDef: b2FixtureDef
			b2World: b2World
	
} = require 'Physics/box2D'

Config = require 'Config'
Entity = require 'Entity/Entity'

contactListener = new b2ContactListener

contactListener.BeginContact = (contact) ->
	
	l = contact.GetFixtureA().GetBody().GetUserData()
	r = contact.GetFixtureB().GetBody().GetUserData()
	
	return unless l instanceof Entity and r instanceof Entity
	
	l.setIsTouching r
	r.setIsTouching l
	
contactListener.EndContact = (contact) ->
	
	l = contact.GetFixtureA().GetBody().GetUserData()
	r = contact.GetFixtureB().GetBody().GetUserData()
	
	return unless l instanceof Entity and r instanceof Entity
	
	l.unsetIsTouching r
	r.unsetIsTouching l
	
contactFilter = new b2ContactFilter

ShouldCollide = contactFilter.ShouldCollide

contactFilter.ShouldCollide = (fixtureA, fixtureB) ->
	
	return false unless ShouldCollide.call this, fixtureA, fixtureB
	
	l = fixtureA.GetBody().GetUserData()
	r = fixtureB.GetBody().GetUserData()
	
	return true unless l instanceof Entity and r instanceof Entity
	
	return true unless l.isInMainParty() and r.isInMainParty()
	
	return false

module.exports = class Box2D extends (require 'Physics/AbstractPhysics')
	
	constructor: (
		gravity = 0
	) ->
		super
		
		@_world = new b2World(
			new b2Vec2 0, gravity
			true
		)
		
#		@_world.SetContactListener contactListener
#		@_world.SetContactFilter contactFilter
		
	addFloor: ->
	
	addSphere: (entity, radius, mass = 1) ->

		bodyDef = new b2BodyDef()
		bodyDef.type = if mass is 0
			b2Body.b2_staticBody
		else
			b2Body.b2_dynamicBody
		
		body = @_world.CreateBody bodyDef
		
		circle = new b2CircleShape()
		circle.SetRadius radius
		
		fixtureDef = new b2FixtureDef()
		fixtureDef.shape = circle
		fixtureDef.density = mass
		fixtureDef.friction = 0
		
		body.CreateFixture fixtureDef
		body.SetUserData entity
		
		body
	
	addCylinder: (entity, radius, height = 1, mass = 1) ->
	
	removeBody: (body) -> @_world.DestroyBody body
	
	_createLayerFixture: (layer) ->
	
		fixtureDef = new b2FixtureDef
		fixtureDef.density = 1
		fixtureDef.friction = 0
		fixtureDef.filter.categoryBits = if layer is -1
			(1 << 5) - 1
		else
			1 << layer
			
		fixtureDef.filter.maskBits = fixtureDef.filter.categoryBits
		
		fixtureDef
		
	_createRoomEdges: (wall) ->
		
		wall.isALoop ?= true
		wall.layer ?= -1
		
		fixtureDef = @_createLayerFixture wall.layer
		fixtureDef.shape = new b2PolygonShape()
		
		for vertice, i in wall.vertices
			
			nextVertice = if i is wall.vertices.length - 1
				if wall.isALoop then wall.vertices[0] else null
			else
				wall.vertices[i + 1]
				
			break unless nextVertice?
			
			vertice = Box2D.toVector vertice
			nextVertice = Box2D.toVector nextVertice
			
			fixtureDef.shape.SetAsEdge(
				new b2Vec2 vertice[0], vertice[1]
				new b2Vec2 nextVertice[0], nextVertice[1]
			)
			
			@_world.GetGroundBody().CreateFixture fixtureDef

	setWalls: (size) ->
		
		## Room outer boundaries
		@_createRoomEdges
			
			vertices: [
				[0, 0]
				[size[0] - 1, 0]
				[size[0] - 1, size[1] - 1]
				[0, size[1] - 1]
			]
		
		return

	step: -> @_world.Step 1 / Config.Physics.Tps, 8, 3
		
	@position: (body) ->
		{x, y} = body.GetPosition()
		[x, y]
	
	@radius: (body) -> .25

	@setLayer: (body, layer) ->
		return unless body?
	
		filter = (fixture = body.GetFixtureList()).GetFilterData()
		filter.categoryBits = 1 << layer
		filter.maskBits = if true#@state.solid
			filter.categoryBits
		else
			0

		fixture.SetFilterData filter

	@setPosition: (body, position) ->
		body.SetPosition new b2Vec2 position[0], position[1]

	@setSize: (body, size) ->
		return unless body?
#		
#		body.shape.radius = size
#		body.shape.boundingSphereRadiusNeedsUpdate = true

	@setVelocity: (body, velocity) ->
		body.SetLinearVelocity new b2Vec2 velocity[0], velocity[1]
		body.SetAwake true unless body.IsAwake()

	@velocity: (body) ->
		{x, y} = body.GetLinearVelocity()
		[x, y]
