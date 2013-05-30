
Rectangle = require 'Extension/Rectangle'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait
	
	stateDefaults: ->
		
		layer: 1
		saveWithRoom: true
	
	constructor: (entity, state) ->
		
		super entity, state
		
		@room = null

	setVariables: (variables) -> @room = variables.room if variables.room?
	
	actions: ->
		
		setLayer: (layer) -> @state.layer = layer
	
	values: ->
		
		room: -> @room

		layer: -> @state.layer
		
		saveWithRoom: -> @state.saveWithRoom