
Promise = require 'avo/vendor/bluebird'

Collection = require './collection'
Invocation = require './invocation'

module.exports = class Actions extends Collection 'actions'

  constructor: ->
  	super

  	@_index = 0
  	@_state = null

  index: -> @_index

  _finalize: (increment) ->

  	@_state.cleanUp() if @_state?

  	@setIndex (@_index + increment) % @_actions.length

  	@_state = null

  invoke: (context) ->
  	return if @_actions.length is 0

  	if @_state?

  		@_state.tick()
  		return

  	state = new Invocation.State()
  	@_actions[@_index].invoke context, state

  	# Waiting...
  	if (promise = state.promise())?

  		promise.then (result) => @_finalize result?.increment ? 1

  		@_state = state

  	else

  		# Otherwise, just increment by 1.
  		@_finalize 1

  	promise

  invokeImmediately: (context, state) ->

  	actionStates = for action in @_actions
  		action.invoke context, actionState = new Invocation.State()
  		actionState

  	# Any actual action promises?
  	if actionStates.reduce ((l, r) -> r.promise()? and l), true

  		state.setTicker ->
  			for actionState in actionStates
  				actionState.tick()

  		state.setPromise Promise.all actionStates.map (e) -> e.promise()

  setIndex: (index) -> @_index = index
