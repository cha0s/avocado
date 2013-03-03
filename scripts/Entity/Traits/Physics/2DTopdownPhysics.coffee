
Box2D = require 'Physics/Box2D'
Physics = require 'Entity/Traits/Physics'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Physics
	
	defaults: ->
		
		super
		
	hooks: ->
		
		moveRequest: (hypotenuse) ->
			
			return unless @world?
			return unless @body?
			
			hypotenuse = Vector.scale(
				hypotenuse, @entity.movingSpeed() / Physics.PixelsPerMeter
			)
			
			@entity.emit 'moving', hypotenuse
			
			request = Vector.scale(
				hypotenuse
				@state.floorFriction
			)
			
			@moveBody @body, request, hypotenuse
			
	handler: ->
		
		ticker:
			
			weight: -100
			f: ->
				
				return unless @world?
				return unless @body?
				
				{x, y} = @body.GetLinearVelocity()
				
				unless x is 0 and y is 0
					
					velocity = Vector.scale(
						[-x, -y]
						@state.floorFriction
					)
					@body.ApplyImpulse(
						new Box2D.b2Vec2 velocity[0], velocity[1]
						@body.GetWorldCenter()
					)
					
				{x, y} = @body.GetPosition()
				
				@entity.setPosition Vector.scale(
					[x, -y]
					Physics.PixelsPerMeter
				)
