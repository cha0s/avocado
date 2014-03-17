
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
	
} = require './box2D'

Config = require '../Config'
Entity = require '../Entity/Entity'

contactListener = new b2ContactListener

contactListener.BeginContact = (contact) ->
	
	lf = contact.GetFixtureA()
	return unless ldata = lf.GetUserData()
	le = ldata.entity
	ls = ldata.shape
	
	rf = contact.GetFixtureB()
	return unless rdata = rf.GetUserData()
	re = rdata.entity
	rs = rdata.shape
	
	return unless le instanceof Entity and re instanceof Entity
	
	le.emit 'intersected', re, rs, ls
	re.emit 'intersected', le, ls, rs
	
module.exports = class Box2D extends (require './AbstractPhysics')
	
	constructor: (
		gravity = 0
	) ->
		super
		
		@_world = new b2World(
			new b2Vec2 0, gravity
			true
		)
		
		@_world.SetContactListener contactListener
		
	addFloor: ->
	
	addBody: (entity, shapeList) ->
		
		bodyDef = new b2BodyDef()
		bodyDef.type = if entity.immovable()
			b2Body.b2_staticBody
		else
			b2Body.b2_dynamicBody
		
		body = @_world.CreateBody bodyDef
		
		for shape in shapeList.shapes()
			
			fixtureDef = new b2FixtureDef()
			
			switch shape.type()
				
				when 'CircleShape'
					
					circle = new b2CircleShape()
					circle.SetRadius Box2D.toScalar shape.radius()
					fixtureDef.shape = circle
					
#				when 'RectangleShape'
#				
#					box = new b2PolygonShape()
#					box.SetAsBox @state.radius / Physics.PixelsPerMeter, @state.radius / Physics.PixelsPerMeter 
					
			fixtureDef.density = shape.density()
			fixtureDef.friction = 0
			
			fixture = body.CreateFixture fixtureDef
			fixture.SetUserData(
				shape: shape
				entity: entity
			)
		
		body.SetUserData(
			entity: entity
			shapeList: shapeList
		)
		
		body
	
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
	
	@mass: (body) -> body.GetMass()
	
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
