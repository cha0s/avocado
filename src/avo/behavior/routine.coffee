
Actions = require './actions'
BehaviorItem = require './behaviorItem'
Invocation = require './invocation'
Rules = require './rules'

Promise = require 'avo/vendor/bluebird'

module.exports = class Routine extends BehaviorItem

	constructor: ->
		
		@_actions = new Actions()
		@_index = 0
		@_rules = new Rules()
		@_state = null
		
	fromObject: (O) ->
		
		Promise.allAsap [
			@_rules.fromObject O.rules
			@_actions.fromObject O.actions
		], => this
	
	index: -> @_index
	
	_finalize: (increment) ->
		
		@_state.cleanUp() if @_state?
		
		@setIndex (@_index + increment) % @_actions.count()
		
		@_state = null
	
	invoke: (context) ->
		
		@_rules.invoke context
		
		if @_state?
			
			@_state.tick()
			return
			
		state = new Invocation.State()
		@_actions.action(@_index).invoke context, state
		
		# Waiting...
		if (promise = state.promise())?
		
			promise.then (result) => @_finalize result?.increment ? 1

			@_state = state
		
		else
			
			# Otherwise, just increment by 1.
			@_finalize 1
			
		return
	
	setIndex: (index) -> @_index = index
	
	toJSON: ->

		rules: @_rules.toJSON()
		actions: @_actions.toJSON()
