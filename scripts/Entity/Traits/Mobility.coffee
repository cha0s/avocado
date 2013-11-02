
Timing = require 'Timing'

Config = require 'Config'
Q = require 'Utility/kew'
String = require 'Extension/String'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	stateDefaults: ->
		
		isMobile: true
		isMoving: false
		mobilityAnimationIndex: 'moving'
		movingSpeed: 0
	
	properties: ->
		
		isMobile: {}
		isMoving: {}
		mobilityAnimationIndex: {}
		movingSpeed: {}
	
	actions: ->

		move: (vector) ->
			
			@entity.setDirection(
				Vector.toDirection vector, @entity.directionCount()
			)
			
			return unless @entity.isMobile()
			
			@entity.setIsMoving not Vector.isZero vector
			
			@entity.forceMove vector, @entity.movingSpeed()

		moveToward:
			
			frequency: 1000 / Config.Physics.Tps
			f: (destination, timeout = Infinity) ->
				
				deferred = Q.defer()
				
				timeout /= 1000
				
				ticker = f: =>
					
					@entity.move hypotenuse = Vector.hypotenuse(
						destination
						@entity.position()
					)
					
					entityPosition = @entity.position()
					for i in [0, 1] when hypotenuse[i] isnt 0
						
						if hypotenuse[i] < 0
							if entityPosition[i] < destination[i]
								entityPosition[i] = destination[i]
						
						if hypotenuse[i] > 0
							if entityPosition[i] > destination[i]
								entityPosition[i] = destination[i]
					
					@entity.setPosition entityPosition
					return deferred.resolve() if Vector.equals(
						destination
						entityPosition
					)
					
					timeout -= Timing.TimingService.tickElapsed()
					deferred.resolve() if timeout <= 0
				
				ticker = @entity.addTicker ticker
				
				deferred.promise.then =>
					@entity.removeTicker ticker
					
					@entity.setIsMoving false
					