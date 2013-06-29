
# # Main
# 
# Execution context. The "main loop" of the Avocado engine.
Graphics = require 'Graphics'

Cps = require 'Timing/Cps' 
EventEmitter = require 'Mixin/EventEmitter'
PrivateScope = require 'Utility/PrivateScope'
StateMachine = require 'State/StateMachine'
Timing = require 'Timing'

# #### Construction
# Uses a [state machine](./State/StateMachine.html) to handle engine states, 
# and handles fixed-step tick timing.
module.exports = Main = class
	
	constructor: ->
		EventEmitter.call this
		
		PrivateScope.call @, Private, 'mainScope'
		
		# Enter the 'Initial' state. This is implemented by your game.
		@transitionToState 'Initial'
		
	# #### Emits
	# 
	# * `error` - When an error was encountered.
	# * `quit` - When the engine is shutting down.
	# * `stateConstructed` - When constructing a state.
	# * `stateLeft` - When leaving a state.
	# * `stateInitialized` - When initializing a state.
	# * `stateEntered` - When entering a state.
	# * `tick` - When the engine ticks.
	# 
	EventEmitter.Mixin @::
	
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'mainScope'
	)
	
	# ##### begin
	# 
	# Start asynchronous execution. Calling again before calling
	# `quit()` is a no-op.
	forwardCallToPrivate 'begin'
		
	# ##### transitionToState
	# * `name` - The name of the state.
	# * `args` - The arguments passed to `State::enter()`.
	# 
	# Change state on the next tick.
	transitionToState: (name, args = {}) ->
		
		_private = @mainScope Private
		_private.stateMachine.transitionToState name, args
	
	# ##### currentStateInstance
	# 
	# Returns a reference to the current state instance.
	currentStateInstance: ->
		
		_private = @mainScope Private
		_private.stateMachine.currentStateInstance()
	
	# ##### tick
	# 
	# Tick the engine, exposed so that subclasses can augment their ticks.
	# Emits the `tick` event.
	forwardCallToPrivate 'tick'
	
	# ##### tps
	# 
	# Returns the ticks per second the engine is achieving.
	tps: ->
		
		_private = @mainScope Private
		_private.tickCps.count()
	
	# ##### quit
	# 
	# Stop execution: Clear intervals and emit the `quit` event.
	# Calling before calling `begin()` is a no-op.
	forwardCallToPrivate 'quit'
	
	# #### Private
	# Implementation details follow...
	Private = class
		
		constructor: (_public) ->

			@stateMachine = new StateMachine()
			@stateMachine.on 'stateLeft', (name) => _public.emit 'stateLeft', name
			@stateMachine.on 'stateConstructed', (state) => state.main = _public
			@stateMachine.on 'stateInitialized', (name) => _public.emit 'stateInitialized', name
			@stateMachine.on 'stateEntered', (name) => _public.emit 'stateEntered', name
			
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
			@lastElapsed = 0
			@tickFrequency = 1000 / Timing.ticksPerSecondTarget
			@tickTargetSeconds = 1 / Timing.ticksPerSecondTarget
			@tickRemainder = 0
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
			@tickRemainder += elapsed - @lastElapsed
			@lastElapsed = elapsed
			
			_public = @public()
			
			while @tickRemainder > @tickTargetSeconds
				@tickCps.tick()
				@stateMachine.tick()
				_public.emit 'tick'
				
				@tickRemainder -= @tickTargetSeconds
				
			return
