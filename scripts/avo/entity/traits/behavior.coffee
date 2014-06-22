
Routines = require 'avo/behavior/routines'
Rules = require 'avo/behavior/rules'

Promise = require 'avo/vendor/bluebird'
Trait = require './trait'

module.exports = Behavior = class extends Trait

	stateDefaults: ->
		
		behaving: true
		routineIndex: 'initial'
		routines: {}
		rules: []
	
	constructor: (entity, state) ->
		super
		
		@_routines = new Routines()
		@_rules = new Rules()
		
	initializeTrait: ->
		
		Promise.allAsap [
			@_routines.fromObject @state.routines
			@_rules.fromObject @state.rules
		], =>
			
			@_routines.setIndex @state.routineIndex
		
	properties: ->
		
		behaving: {}
		routineIndex:

			set: (routineIndex) ->
				@_routines.setIndex @state.routineIndex = routineIndex
		
	actions: ->
		
		parallel: (actions, state) ->
			
			actions.invokeImmediately @entity.context(), state
		
	handler: ->
		
		ticker: ->
			
			return unless @entity.behaving()
			
			@_rules.invoke @entity.context()
			
			@_routines.routine().invoke @entity.context()
			
			return
