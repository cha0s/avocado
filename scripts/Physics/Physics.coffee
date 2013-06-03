
CANNON = require 'Physics/cannon'
Config = require 'Config'

module.exports = Physics = class
	
	@PixelsToMetersScale: 1 / 64

	constructor: (
		gravity = new CANNON.Vec3 0, 0, -9.82
	) ->
		
		@_walls = []
		
		@_world = new CANNON.World()
		gravity.copy @_world.gravity
		@_world.broadphase = new CANNON.NaiveBroadphase()
		
	addFloor: ->
	
		groundShape = new CANNON.Plane()
		groundBody = new CANNON.RigidBody 0, groundShape
		
		groundBody.collisionFilterGroup = 1
		groundBody.collisionFilterMask = 63
		
		@_world.add groundBody
		
		return
		
	setWalls: (size) ->
		
		@removeBody wall for wall in @_walls
	
		leftWall = new CANNON.RigidBody 0, new CANNON.Plane()
		leftWall.collisionFilterGroup = 1
		leftWall.collisionFilterMask = 63
		leftWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(0, 1, 0), Math.PI / 2
		)
		leftWall.position.set 0, 0, 0
		@_world.add leftWall
		@_walls.push leftWall
		
		rightWall = new CANNON.RigidBody 0, new CANNON.Plane()
		rightWall.collisionFilterGroup = 1
		rightWall.collisionFilterMask = 63
		rightWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(0, 1, 0), -Math.PI / 2
		)
		rightWall.position.set (size[0] * Physics.PixelsToMetersScale), 0, 0
		@_world.add rightWall
		@_walls.push rightWall
		
		topWall = new CANNON.RigidBody 0, new CANNON.Plane()
		topWall.collisionFilterGroup = 1
		topWall.collisionFilterMask = 63
		topWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(1, 0, 0), -Math.PI / 2
		)
		topWall.position.set 0, 0, 0
		@_world.add topWall
		@_walls.push topWall
		
		bottomWall = new CANNON.RigidBody 0, new CANNON.Plane()
		bottomWall.collisionFilterGroup = 1
		bottomWall.collisionFilterMask = 63
		bottomWall.quaternion.setFromAxisAngle(
			new CANNON.Vec3(1, 0, 0), Math.PI / 2
		)
		bottomWall.position.set 0, (size[1] * Physics.PixelsToMetersScale), 0
		@_world.add bottomWall
		@_walls.push bottomWall

		return
		
	addSphere: (radius, mass = 1) ->
	
		sphereShape = new CANNON.Sphere radius
		sphereBody = new CANNON.RigidBody mass, sphereShape
		@_world.add sphereBody
		
		sphereBody
	
	addCylinder: (radius, height = 1, mass = 1) ->
	
		sphereShape = new CANNON.Cylinder radius, radius, height, 10
		sphereShape = new CANNON.RigidBody mass, sphereShape
		@_world.add sphereShape
		
		sphereShape
	
	removeBody: (body) -> @_world.remove body
		
	tick: ->
	
		@_world.step 1 / Config.ticksPerSecondTarget	
