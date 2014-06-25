
timing = require 'avo/timing'

Promise = require 'avo/vendor/bluebird'
Vector = require 'avo/extension/vector'

Trait = require './trait'

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
			
			isZero = Vector.isZero vector
			
			@entity.setDirection(
				Vector.toDirection vector, @entity.directionCount()
			) unless isZero
			
			return unless @entity.isMobile()
			
			@entity.setIsMoving not isZero
			
			@entity.forceMove vector, @entity.movingSpeed()

		moveToward:
			
			f: (destination, timeout = Infinity, state) ->
				
				deferred = Promise.defer()
				
				timeout /= 1000
				
				state.setPromise deferred.promise
				state.setTicker =>
					
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
					
					timeout -= timing.tickElapsed()
					deferred.resolve() if timeout <= 0
				
				ticker = @entity.addTicker ticker
