
Actions = require 'avo/behavior/actions'
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
		staticActions: []
	
	constructor: (entity, state) ->
		super
		
		@_routines = new Routines()
		@_rules = new Rules()
		@_staticActions = new Actions()
		
	initialize: ->
		
		Promise.allAsap [
			@_routines.fromObject @state.routines
			@_rules.fromObject @state.rules
			@_staticActions.fromObject @state.staticActions
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
			
			context = @entity.context()
			
			@_routines.routine().invoke context
			@_rules.invoke context
			@_staticActions.invoke context
			
			return

	signals: ->
		
		dying: -> @entity.setIsBehaving false
