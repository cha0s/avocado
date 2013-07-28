# ### StateMachine
# 
# Implements a simple state transition system. In practice, it's more like a
# Finite State Machine.
# 
# Avocado uses "states" to implement various functionality. The engine
# is within a state for virtually its entire execution lifetime. See
# [the AbstractState interface documentation](./AbstractState.html).
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Q = require 'Utility/Q'

# #### Construction
# 
# StateMachine is responsible for transitioning to, initializing, entering,
# ticking, and leaving States.
module.exports = StateMachine = class
	
	mixins = [
		EventEmitter
	]
	
	constructor: ->
		
		mixin.call @ for mixin in mixins
		
		@_name = ''
		@_transition = null
		@_instance = null
		@_instanceCache = {}
		
	Mixin.apply null, [@::].concat mixins
	
	# ##### currentStateInstance
	# Returns a reference to the current state instance.
	currentStateInstance: -> @_instance

	_handleTransition: ->
		return unless @_transition?
		
		{name, args} = @_transition
		delete @_transition
		@leave name
		@emit 'stateLeft', @name
		
		promise = Q.asap(
		
			# If the State is already loaded and cached, fulfill the
			# initialization immediately.
			if @_instanceCache[name]?
				true
				
			# Otherwise, instantiate and cache.
			else
				
				@_instanceCache[name] = new (require "State/#{name}")
				@emit 'stateConstructed', @_instanceCache[name]
				@_instanceCache[name].initialize()
				
			=>
				@emit 'stateInitialized', name
				initPromise = Q.asap(
					@_instanceCache[name].enter args, @name
					=>
						@emit 'stateEntered', name
						@_instance = @_instanceCache[@_name = name]
				)
				initPromise.done() if Q.isPromise initPromise
		)
		promise.done() if Q.isPromise promise
		
	leave: (next) ->
		@_instance?.leave next
		@_instance = null
		
	# ##### tick
	# Handle state transitions and invoke the current state (if any)'s tick
	# method.
	tick: ->
		@_instance?.tick()
		@_handleTransition()
		
	# ##### transitionToState
	# Transition to a *name*d state, passing *args* to its initialize/enter
	# method.
	transitionToState: (name, args) ->
		return if @_transition?
		@_transition = name: name, args: args
