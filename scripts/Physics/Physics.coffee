
CANNON = require 'Physics/cannon'
Config = require 'Config'
Ticker = require 'Timing/Ticker'

slippery = new CANNON.Material 'slippery'

slipperyContact = new CANNON.ContactMaterial(
	slippery, slippery, 0, 0.3
)

slipperyContact.contactEquationStiffness = 1e8
slipperyContact.contactEquationRegularizationTime = 2
slipperyContact.frictionEquationStiffness = 1e8
slipperyContact.frictionEquationRegularizationTime = 2

module.exports = Physics = class Physics
	
	constructor: (
		gravity = new CANNON.Vec3 0, 0, -9.82
	) ->
		
		@_ticker = new Ticker.InBand()
		
		@_ticker.setFrequency 1000 / Config.Physics.Tps
		@_ticker.on 'tick', => @_world.step 1 / Config.Physics.Tps
		
		@_walls = []
		
		@_world = new CANNON.World()
		gravity.copy @_world.gravity
		@_world.broadphase = new CANNON.NaiveBroadphase()

		@_world.addContactMaterial slipperyContact
		
	addFloor: ->
	
		groundShape = new CANNON.Plane()
		groundBody = new CANNON.RigidBody 0, groundShape, slippery
		
		groundBody.collisionFilterGroup = 1
		groundBody.collisionFilterMask = 63
		
		@_world.add groundBody
		
		return
		
	_addWall: ->
		wall = new CANNON.RigidBody 0, new CANNON.Plane()
		wall.collisionFilterGroup = 1
		wall.collisionFilterMask = 63
		@_world.add wall
		@_walls.push wall
		wall
		
	setWalls: (size) ->
		
		@removeBody wall for wall in @_walls

		leftWall = @_addWall()
		leftWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(0, 1, 0), Math.PI / 2
		)
		leftWall.position.set 0, 0, 0
		
		rightWall = @_addWall()
		rightWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(0, 1, 0), -Math.PI / 2
		)
		rightWall.position.set (size[0] * Config.Physics.PixelsToMetersScale), 0, 0
		
		topWall = @_addWall()
		topWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(1, 0, 0), -Math.PI / 2
		)
		topWall.position.set 0, 0, 0
		
		bottomWall = @_addWall()
		bottomWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(1, 0, 0), Math.PI / 2
		)
		bottomWall.position.set 0, (size[1] * Config.Physics.PixelsToMetersScale), 0

		return
		
	addSphere: (radius, mass = 1) ->
	
		sphereShape = new CANNON.Sphere radius
		sphereBody = new CANNON.RigidBody mass, sphereShape, slippery
		@_world.add sphereBody
		
		sphereBody
	
	addCylinder: (radius, height = 1, mass = 1) ->
	
		sphereShape = new CANNON.Cylinder radius, radius, height, 10
		sphereShape = new CANNON.RigidBody mass, sphereShape
		@_world.add sphereShape
		
		sphereShape
	
	removeBody: (body) -> @_world.remove body
		
	tick: ->
		
		@_ticker.tick()
