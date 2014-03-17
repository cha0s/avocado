
CANNON = require './cannon'
Config = require '../Config'

slippery = new CANNON.Material 'slippery'

slipperyContact = new CANNON.ContactMaterial(
	slippery, slippery, 0, 0.3
)

slipperyContact.contactEquationStiffness = 1e8
slipperyContact.contactEquationRegularizationTime = 2
slipperyContact.frictionEquationStiffness = 1e8
slipperyContact.frictionEquationRegularizationTime = 2

module.exports = class Cannon extends (require './AbstractPhysics')
	
	constructor: (
		gravity = -9.82
	) ->
		super
		
		gravity = new CANNON.Vec3 0, 0, gravity
		
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
		
	addBody: (entity, shapeList) ->
		
	addSphere: (entity, position, radius, mass = 1) ->
	
		sphereShape = new CANNON.Sphere radius
		sphereBody = new CANNON.RigidBody mass, sphereShape, slippery
		@_world.add sphereBody
		
		sphereBody
	
	removeBody: (body) -> @_world.remove body

	setWalls: (size) ->
		
		@removeBody wall for wall in @_walls
		
		size = Cannon.toVector size

		leftWall = @_addWall()
		leftWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(0, 1, 0), Math.PI / 2
		)
		leftWall.position.set 0, 0, 0
		
		rightWall = @_addWall()
		rightWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(0, 1, 0), -Math.PI / 2
		)
		rightWall.position.set size[0], 0, 0
		
		topWall = @_addWall()
		topWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(1, 0, 0), Math.PI / 2
		)
		topWall.position.set 0, 0, 0
		
		bottomWall = @_addWall()
		bottomWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(1, 0, 0), -Math.PI / 2
		)
		bottomWall.position.set 0, size[1], 0

		return

	step: -> @_world.step 1 / Config.Physics.Tps
		
	@position: (body) -> [
		body.position.x
		body.position.y
		body.position.z
	]
	
	@radius: (body) -> body.shape.radius

	@setLayer: (body, layer) ->
		return unless body?
		
		layerBit = 1 << (layer + 1)
		
		body.collisionFilterGroup = layerBit
		body.collisionFilterMask = layerBit | 1
	
	@setPosition: (body, position) ->
		body.position.set(
			position[0]
			position[1]
			
			# TODO this default is hackish.
			position[2] ? .25
		)

	@setSize: (body, size) ->
		return unless body?
		
		body.shape.radius = size
		body.shape.boundingSphereRadiusNeedsUpdate = true

	@setVelocity: (body, velocity) ->
		body.velocity.set(
			velocity[0]
			velocity[1]
			
			# TODO this default is hackish.
			velocity[2] ? body.velocity.z
		)

	@velocity: (body) -> [
		body.velocity.x
		body.velocity.y
		body.velocity.z
	]
	