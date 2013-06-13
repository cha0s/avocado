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
PrivateScope = require 'Utility/PrivateScope'
Q = require 'Utility/Q'

# #### Construction
# 
# StateMachine is responsible for transitioning to, initializing, entering,
# ticking, and leaving States.
module.exports = StateMachine = class
	
	constructor: ->
		PrivateScope.call @, Private
		
		# Emits:
		# 
		# * <code>stateConstructed</code>: When constructing a state.
		# * <code>stateLeft</code>: When leaving a state.
		# * <code>stateInitialized</code>: When initializing a state.
		# * <code>stateEntered</code>: When entering a state.
		Mixin this, EventEmitter
	
	# ##### currentStateInstance
	# Returns a reference to the current state instance.
	currentStateInstance: -> @private().instance
	
	# ##### tick
	# Handle state transitions and invoke the current state (if any)'s tick
	# method.
	tick: -> @private().tick()
	
	# ##### transitionToState
	# Transition to a *name*d state, passing *args* to its initialize/enter
	# method.
	transitionToState: (name, args) -> @private().transitionTo name, args

	# #### Private
	# Implementation details follow...
	Private = class
		
		constructor: ->
			@name = ''
			@transition = null
			@instance = null
			@instanceCache = {}
		
		handleTransition: ->
			return unless @transition?
			
			_public = @public()
			
			{name, args} = @transition
			delete @transition
			@leave name
			_public.emit 'stateLeft', @name
			
			Q.asap(
			
				# If the State is already loaded and cached, fulfill the
				# initialization immediately.
				if @instanceCache[name]?
					true
					
				# Otherwise, instantiate and cache.
				else
					
					@instanceCache[name] = new (require "State/#{name}")
					_public.emit 'stateConstructed', @instanceCache[name]
					@instanceCache[name].initialize()
					
				=>
					_public.emit 'stateInitialized', name
					Q.asap(
						@instanceCache[name].enter args, @name
						=>
							_public.emit 'stateEntered', name
							@instance = @instanceCache[@name = name]
					).done()
			).done()
			
		leave: (next) ->
			@instance?.leave next
			@instance = null
			
		tick: ->
			@instance?.tick()
			@handleTransition()
			
		transitionTo: (name, args) ->
			return if @transition?
			@transition = name: name, args: args
			
		public: -> @getScope()
	
	private: -> @getScope Private
	