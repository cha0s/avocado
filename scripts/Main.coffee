
# # Main
# 
# Execution context. The "main loop" of the Avocado engine.
# 
# Uses a [`StateMachine`](./State/StateMachine.html) to handle engine states, 
# and handles fixed-step tick timing.
Graphics = require 'Graphics'

Cps = require 'Timing/Cps' 
EventEmitter = require 'Mixin/EventEmitter'
FunctionExt = require 'Extension/Function'
Mixin = require 'Mixin/Mixin'
StateMachine = require 'State/StateMachine'
Timing = require 'Timing'

module.exports = Main = class Main
	
	mixins = [
	
		# #### Emits
		# 
		# * `beforeTick` - Before the engine ticks.
		# * `error` - When an error was encountered.
		# * `quit` - When the engine is shutting down.
		# * `stateConstructed` - When constructing a state.
		# * `stateEntered` - When entering a state.
		# * `stateLeft` - When leaving a state.
		# * `stateInitialized` - When initializing a state.
		# * `tick` - When the engine ticks.
		# 
		EventEmitter
	]
	
	constructor: ->

		mixin.call this for mixin in mixins
		
		@_stateMachine = new StateMachine()
		@_stateMachine.on 'stateLeft', (name) => @emit 'stateLeft', name
		@_stateMachine.on 'stateConstructed', (state) => state.main = @
		@_stateMachine.on 'stateInitialized', (name) => @emit 'stateInitialized', name
		@_stateMachine.on 'stateEntered', (name) => @emit 'stateEntered', name
		
		# #### Timing
		# 
		# Timing within the engine is handled in fixed steps. If the engine
		# falls behind the requested ticks per second, multiple fixed steps
		# will occur every tick.
		# 
		# * Keep track of cycles per second.
		# * Keep handles for our tick loop, so we can GC it on quit.
		@_tickCps = new Cps()
		@_tickInterval = null
		
		# [Fix your timestep!](http://gafferongames.com/game-physics/fix-your-timestep/)
		@_lastElapsed = 0
		@_tickFrequency = 1000 / Timing.ticksPerSecondTarget
		@_tickTargetSeconds = 1 / Timing.ticksPerSecondTarget
		@_tickRemainder = 0
		Timing.TimingService.setTickElapsed @_tickTargetSeconds
		
		# Enter the 'Initial' state. This is implemented by your game.
		@transitionToState 'Initial'

	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	# ##### begin
	# 
	# Start asynchronous execution. Calling again before calling
	# `quit()` is a no-op.
	begin: ->
		return if @_tickInterval?
		
		@_tickInterval = setInterval(
			=>
				try
					@tick()
				catch error
					@emit 'error', error
			@_tickFrequency
		)
		
	# ##### currentStateInstance
	# 
	# Returns a reference to the current state instance.
	currentStateInstance: -> @_stateMachine.currentStateInstance()
	
	# ##### quit
	# 
	# Stop execution: Clear intervals and emit the `quit` event.
	# Calling before calling `begin()` is a no-op.
	quit: ->
		return unless @_tickInterval?
		
		clearInterval @_tickInterval
		@_tickInterval = null
		
		@emit 'quit'

	tick: ->
	
		@emit 'beforeTick'
			
		elapsed = Timing.TimingService.elapsed()
		@_tickRemainder += elapsed - @_lastElapsed
		@_lastElapsed = elapsed
		
		while @_tickRemainder > @_tickTargetSeconds
			@_tickCps.tick()
			@_stateMachine.tick()
			@emit 'tick'
			
			@_tickRemainder -= @_tickTargetSeconds
			
		return
	
	# ##### tps
	# 
	# Returns the ticks per second the engine is achieving.
	tps: -> @_tickCps.count()
	
	# ##### transitionToState
	# * `name` - The name of the state.
	# * `args` - The arguments passed to `State::enter()`.
	# 
	# Change state on the next tick.
	transitionToState: (name, args = {}) ->
		@_stateMachine.transitionToState name, args
