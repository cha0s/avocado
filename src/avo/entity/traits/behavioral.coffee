
Routines = require 'avo/behavior/routines'
Rules = require 'avo/behavior/rules'

Promise = require 'avo/vendor/bluebird'
Trait = require './trait'

module.exports = Behavioral = class extends Trait

	stateDefaults: ->
		
		isBehaving: true
		routineIndex: 'initial'
		routines: {}
		rules: []
	
	constructor: (entity, state) ->
		super
		
		@_routines = new Routines()
		@_rules = new Rules()
		
	initialize: ->
		
		Promise.allAsap [
			@_routines.fromObject @state.routines
			@_rules.fromObject @state.rules
		], =>
			
			@_routines.setIndex @state.routineIndex
		
	properties: ->
		
		isBehaving: {}
		routineIndex:

			set: (routineIndex) ->
				
				@_routines.setIndex @state.routineIndex = routineIndex
		
	actions: ->
		
		parallel: (actions, state) ->
			
			actions.invokeImmediately @entity.context(), state
		
	handler: ->
		
		ticker: ->
			
			return unless @entity.isBehaving()
			
			@_rules.invoke @entity.context()
			
			@_routines.routine().invoke @entity.context()
			
			return

	signals: ->
		
		dying: -> @entity.setIsBehaving false
