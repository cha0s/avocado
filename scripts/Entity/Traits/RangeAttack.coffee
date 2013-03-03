Entity = require 'Entity/Entity'
Trait = require 'Entity/Traits/Trait'
Physics = require 'Entity/Traits/Physics'
Vector = require 'Extension/Vector'

module.exports = RangeAttack = class extends Trait
	
	defaults: ->
		
		radius: 4
		layer: 1
		solid: true
		velocity: 180
		density: 0
		type: 'star'
	
	constructor: ->
		
		super
		
		@projectiles = {}
		@id = 0
		@deadProjectiles = []
		
	spawnProjectile: (position, hypotenuse) ->
		
		physics = @entity.trait 'Physics'
		
		body = physics.createBody @state
		body.SetPosition physics.translatePhysicsPosition [
			position[0]
			-position[1]
		]
		
		data = body.GetUserData()
		
		data.weapon = @entity.rangeWeapon()
		
		hypotenuse = Vector.scale(
			hypotenuse, @state.velocity / Physics.PixelsPerMeter
		)
		
		data.id = @id++
		
		@projectiles[data.id] =
			position: position
			body: body
			weapon: @entity.rangeWeapon()
			hypotenuse: hypotenuse
		
	spawnDirectedProjectile: ->
		
		position = @entity.position()

		@spawnProjectile(
			position
			Vector.fromDirection @entity.direction()
		)
	
	spawnOrientedProjectile: ->
		
		position = @entity.position()
		target = Entity.main

		@spawnProjectile(
			position
			Vector.hypotenuse(
				target.position()
				position
			)
		)
	
	spawnCrossProjectiles: ->
		
		position = @entity.position()
		
		for i in [0...4]
	
			@spawnProjectile(
				position
				Vector.fromDirection i
			)
		
	spawnXProjectiles: ->
	
		position = @entity.position()
		
		for i in [4...8]
	
			@spawnProjectile(
				position
				Vector.fromDirection i
			)
		
	spawnProjectiles: ->
		
		switch @state.type
			
			when 'directed'
				
				@spawnDirectedProjectile()
		
			when 'oriented'
				
				@spawnOrientedProjectile()
		
			when 'cross'
			
				@spawnCrossProjectiles()
				
			when 'x'
			
				@spawnXProjectiles()
				
			when 'star'
		
				@spawnCrossProjectiles()
				@spawnXProjectiles()
				
	signals: ->
		
		collisionStart: (self, other) ->
			
			return unless @projectiles[self.id]?
			
			@deadProjectiles.push @projectiles[self.id]
			delete @projectiles[self.id]
			
	actions: ->
		
		rangeAttack: ->
			
			@spawnProjectiles()
			
	handler: ->
		
		ticker: ->
			
			physics = @entity.trait 'Physics'
			
			for deadProjectile in @deadProjectiles
				physics.world.DestroyBody deadProjectile.body
			@deadProjectiles = []
			
			for key, projectile of @projectiles
				
				{body, hypotenuse} = projectile
				
				{x, y} = body.GetPosition()
				
				projectile.position = Vector.scale(
					[x, -y]
					Physics.PixelsPerMeter
				)
				
				physics.moveBody body, hypotenuse, hypotenuse
				
		renderer: (destination, position, clip) ->
			
			for key, projectile of @projectiles
				
				pPosition = Vector.sub projectile.position, @entity.position()
				
				projectile.weapon.renderCurrentAnimation(
					Vector.add position, pPosition
					[0, 0, 0, 0]
					destination
				)
