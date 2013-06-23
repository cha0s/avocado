
# # Main
# 
# Abstract execution context. Stuff that happens regardless of the platform
# we're running on.
Graphics = require 'Graphics'

Cps = require 'Timing/Cps' 
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Q = require 'Utility/Q'
StateMachine = require 'State/StateMachine'
Timing = require 'Timing'

# #### Construction
# Implements the main engine loop. Uses a [state machine](./State/StateMachine.html)
# to handle engine states, and handles fixed-step tick timing.
# 
# Subclass this to implement platform-specific functionality.
# 
module.exports = Main = class
	
	constructor: ->
		PrivateScope.call @, Private
		
		stateMachine = @private().stateMachine
		
		# Emits:
		# 
		# * <code>error</code>: When an error was encountered.
		# * <code>quit</code>: When the engine is shutting down.
		# * <code>stateConstructed</code>: When constructing a state.
		# * <code>stateLeft</code>: When leaving a state.
		# * <code>stateInitialized</code>: When initializing a state.
		# * <code>stateEntered</code>: When entering a state.
		# 
		Mixin this, EventEmitter
		stateMachine.on 'stateLeft', (name) => @emit 'stateLeft', name
		stateMachine.on 'stateConstructed', (state) => state.main = @
		stateMachine.on 'stateInitialized', (name) => @emit 'stateInitialized', name
		stateMachine.on 'stateEntered', (name) => @emit 'stateEntered', name
		
	# ##### begin
	# Start asynchronous execution. Calling again before calling
	# <code>quit()</code> is a no-op.
	begin: -> @private().begin()
		
	# ##### transitionToState
	# Change state on the next tick.
	transitionToState: (name, args = {}) -> 
		@private().stateMachine.transitionToState name, args
	
	# ##### currentStateInstance
	# Returns a reference to the current state instance.
	currentStateInstance: -> @private().stateMachine.currentStateInstance()
	
	# ##### tick
	# Tick the engine, exposed so that subclasses can augment their ticks.
	tick: -> @private().tick()
	
	# ##### tps
	# Returns the ticks per second the engine is achieving.
	tps: -> @private().tickCps.count()
	
	# ##### quit
	# Stop execution: Clear intervals and emit the <code>quit</code> event.
	quit: -> @private().quit()
	
	# #### Private
	# Implementation details follow...
	Private = class
		
		constructor: ->

			@stateMachine = new StateMachine()
			
			# #### Timing
			# 
			# Timing within the engine is handled in fixed steps. If the engine
			# falls behind the requested ticks per second, multiple fixed steps
			# will occur every tick.
			# 
			# * Keep track of cycles per second.
			# * Keep handles for our tick loop, so we can GC it on quit.
			@tickCps = new Cps()
			@tickInterval = null
			
			# [Fix your timestep!](http://gafferongames.com/game-physics/fix-your-timestep/)
			@tickFrequency = 1000 / Timing.ticksPerSecondTarget
			@tickTargetSeconds = 1 / Timing.ticksPerSecondTarget
			@lastElapsed = 0
			@elapsedPending = 0
			Timing.TimingService.setTickElapsed @tickTargetSeconds
		
		begin: ->
			return if @tickInterval?
			
			_public = @public()
			
			@tickInterval = setInterval(
				=>
					try
						_public.tick()
					catch error
						_public.emit 'error', error
				@tickFrequency
			)
			
		quit: ->
			return unless @tickInterval?
			
			clearInterval @tickInterval
			@tickInterval = null
			
			@public().emit 'quit'

		tick: ->
		
			elapsed = Timing.TimingService.elapsed()
			@elapsedPending += elapsed - @lastElapsed
			@lastElapsed = elapsed
			
			_public = @public()
			
			while @elapsedPending > @tickTargetSeconds
				@tickCps.tick()
				@stateMachine.tick()
				_public.emit 'tick'
				
				@elapsedPending -= @tickTargetSeconds
				
			return
		
		public: -> @getScope()
	
	private: -> @getScope Private
