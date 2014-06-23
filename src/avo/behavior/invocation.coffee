
FunctionExt = require 'avo/extension/function'
Promise = require 'avo/vendor/bluebird'

Behavior = require './index'
BehaviorItem = require './behaviorItem'

module.exports = class Invocation extends BehaviorItem
	
	constructor: ->
		
		@_key = ''
		@_selector = []
		@_args = []
	
	fromObject: (O) ->

		[@_key, @_selector...] = O.selector.split ':'
		
		Promise.allAsap( 
			args.map((arg) -> Behavior.instantiate arg) for args in O.args
			(@_args) => this
		)
	
	invoke: (context, state) ->
		return unless context?
		return unless (O = context[@_key])?
		return O if @_selector.length is 0
		
		step = 0
		holder = O

		invoke = =>
			return O if 'function' isnt typeof O
			
			args = (arg.get context for arg in @_args[step - 1])
			args ?= []
			args.push state
			
			FunctionExt.fastApply O, args, holder
		
		while step < @_selector.length
			O = O[@_selector[step++]]
			holder = O = invoke()
			
		invoke()

	toJSON: -> v:

		selector: [@_key].concat(@_selector).join ':'
		args: @_args.map (args) -> args.map (arg) -> arg.toJSON()

class Invocation.State
	
	constructor: ->
		
		@_cleanup = null
		@_promise = null
		@_ticker = null
	
	cleanUp: -> @_cleanup?()
	setCleanup: (@_cleanup) ->

	promise: -> @_promise
	setPromise: (@_promise) ->
	
	tick: -> @_ticker?()
	setTicker: (@_ticker) ->
