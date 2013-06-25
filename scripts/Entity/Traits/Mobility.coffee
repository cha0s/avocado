
TimingService = require('Timing').TimingService
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	stateDefaults: ->
		
		mobile: true
		movingSpeed: 0
		mobilityAnimationIndex: 'moving'
	
	constructor: (entity, state) ->
		
		super entity, state
		
		@isMoving = false
	
	
	properties: ->
		
		mobilityAnimationIndex: {}
		mobile: {}
		movingSpeed: {}
	
	values: ->

		isMoving: -> @isMoving
	
	signals: ->
	
		startedMoving: -> @isMoving = true
		stoppedMoving: -> @isMoving = false
		
	actions: ->

		forceMove: (vector, force) ->
			return if not @entity.mobile()
			
			@entity.setDirection(
				Vector.toDirection vector, @entity.directionCount()
			)
			
			magnitude = TimingService.tickElapsed() * force
			
			moveInvocations = @entity.invoke(
				'moveRequest'
				vector, magnitude
			)
			
			# If no one cared about movement, we'll just do naive movement.
			if moveInvocations.length is 0
				
				@entity.setPosition Vector.add(
					@entity.position()
					Vector.scale vector, magnitude
				)
		
		move: (vector) ->
			
			@entity.forceMove vector, @entity.movingSpeed()
