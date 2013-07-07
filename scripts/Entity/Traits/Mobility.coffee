
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

		moveToward: (position) ->
			
			@entity.move(
				hypotenuse = Vector.hypotenuse position, @entity.position()
			)
			
			axisKeys = ['width', 'height']
			for i in [0, 1] when hypotenuse[i] isnt 0
				
				axis = @entity[axisKeys[i]]()
				
				if hypotenuse[i] < 0
					if axis < position[i]
						@entity[String.setterName axisKeys[i]] position[i]
				
				if hypotenuse[i] > 0
					if axis > position[i]
						@entity[String.setterName axisKeys[i]] position[i]
				
			increment: 0 + Vector.equals position, @entity.position()
