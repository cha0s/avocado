
Promise = require 'avo/vendor/bluebird'

Collection = require './collection'
Invocation = require './invocation'

module.exports = class Actions extends Collection 'actions'

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
