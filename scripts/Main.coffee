# **Main** implements the main engine loop. This class does everything
# you'd expect in a game loop: user input polling, timing, updating the game
# state (called *tick*ing) and rendering the game state.
#
# Also, States are managed here; instantiated as needed, and entered and left
# as requested.
#
# Subclass this to implement platform-specific functionality.
#
# Emits:
# 
# * <pre>error: When an error was encountered.</pre>
# * <pre>quit:  When the engine is shutting down.</pre>
#

Cps = require 'Timing/Cps' 
EventEmitter = require 'Utility/EventEmitter'
Graphics = require 'Graphics'
Mixin = require 'Utility/Mixin'
Q = require 'Utility/Q'
Timing = require 'Timing'

module.exports = Main = class
	
	constructor: ->
		
		Mixin this, EventEmitter
		
		# Holds the current State's name.
		@stateName = ''
		
		# Contains an object such as:
		# 
		#     {
		#         name: 'Initial',
		#         args: {
		#             ...
		#         }
		#     }
		#
		# or if no state change is being requested, undefined.
		
		# Hold the current State object.
		@stateObject = null
		
		# A cache of all instantiated State objects.
		@states = {}
		
		# Keep track of cycles-per-second.
		@tickCps = new Cps()
		
		# Keep handles for out tick and render loops, so we can GC them on
		# quit.
		@tickInterval = null
		
		# [Fix your timestep!](http://gafferongames.com/game-physics/fix-your-timestep/)
		@tickFrequency = 1000 / Timing.ticksPerSecondTarget
		@tickTargetSeconds = 1 / Timing.ticksPerSecondTarget
		@lastElapsed = 0
		@elapsedRemainder = 0
		
	begin: ->
		
		# Tick loop.
		@tickInterval = setInterval(
			=>
				try
					@tick()
				catch error
					@emit 'error', error
			@tickFrequency
		)
		
	# Change the State. This isn't immediate, but will be dispatched on the
	# next tick.
	changeState: (name, args = {}) -> @stateChange = name: name, args: args
	
	# Leave any State we're currently in and NULL the object so
	# State::tick and State::render don't run until the next State is
	# loaded.
	leaveState: (stateName) ->
	
		@stateObject?.leave stateName
		@stateObject = null
		
	# Handle the last State change request.
	handleStateChange: ->
		return unless @stateChange?
		
		# Hold handles to some children in @stateChange since we're going to
		# delete it to signal that we've handled the state change request.
		args = @stateChange.args
		stateName = @stateChange.name

		# We're handling the state change.
		delete @stateChange
		
		@leaveState stateName
		
		# When the State is finished initializing,
		fulfillInitialization = =>
			
			@emit 'stateInitialized', stateName
			
			fulfillEnter = =>
			
				@emit 'stateEntered', stateName
				
				# set the new State name, and the object for
				# ticking/rendering.
				@stateObject = @states[stateName]
				@stateName = stateName
			
			promiseOrResult = @states[stateName].enter(args, @stateName)
			
			if Q.isPromise promiseOrResult
				promiseOrResult.done fulfillEnter
			else
				fulfillEnter()
			
		# If the State is already loaded and cached, fulfill the
		# initialization immediately.
		promiseOrResult = if @states[stateName]?
			true
			
		# Otherwise, instantiate and cache the State.
		else
			
			@states[stateName] = new (require "State/#{stateName}")
			@states[stateName].main = this
			@states[stateName].initialize()
			
		if Q.isPromise promiseOrResult
			promiseOrResult.done fulfillInitialization
		else
			fulfillInitialization()
		
	tick: ->
		
		delta = Timing.TimingService.elapsed() - @lastElapsed
		delta += @elapsedRemainder
		
		# Poll events.
		Graphics.pollEvents()
		
		while delta > @tickTargetSeconds
			delta -= @tickTargetSeconds
			
			Timing.TimingService.setTickElapsed @tickTargetSeconds
			
			# Let the State tick.
			@stateObject?.tick()
			
			# Handle any State change.
			@handleStateChange()
			
			# Track them cycles!
			@tickCps.tick()
		
		@elapsedRemainder = delta
		
		@lastElapsed = Timing.TimingService.elapsed()
	
	quit: ->
		
		@leaveState 'quit'
		
		# GC our tick loop handle.
		clearInterval @tickInterval
		
		# Notify any listeners that it's time to quit.
		@emit 'quit'
