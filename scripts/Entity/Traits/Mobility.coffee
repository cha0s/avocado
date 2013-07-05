
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	stateDefaults: ->
		
		mobilityAnimationIndex: 'moving'
		movingSpeed: 0
	
	constructor: (entity, state) ->
		
		super entity, state
		
		@isMoving = false
	
	properties: ->
		
		mobilityAnimationIndex: {}
		movingSpeed: {}
	
	values: ->

		isMoving: -> @isMoving
	
	signals: ->
	
		startedMoving: -> @isMoving = true
		stoppedMoving: -> @isMoving = false
		
	actions: ->

		move: (vector) ->
			
			@entity.forceMove vector, @entity.movingSpeed()
