
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
