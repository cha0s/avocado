# **Ticker** allows you to keep track of how many discrete ticks have
# passed. Ticks are measured in milliseconds.

Timing = require 'Timing'

EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'

module.exports = Ticker = class

	# Initialize a ticker to count a tick every *frequency* milliseconds.
	constructor: (@frequency, @async = true) ->
		EventEmitter.call this
		
		@reset()
	
	Mixin @::, EventEmitter
		
	# Deep copy a ticker.
	deepCopy: ->
		
		ticker = new Ticker()
		
		ticker.tickRemainder = @tickRemainder
		ticker.frequency = @frequency
		
		ticker.last_ = @last_ if ticker.async = @async
	
	# Reset a ticker, so it will be *@frequency* milliseconds until the next
	# tick.
	reset: ->
		
		@tickRemainder = 0
		@last_ = Timing.TimingService.elapsed() if @async
	
	setFrequency: (@frequency) ->
	
	# Count the number of ticks passed since the last invocation.
	tick: ->
		return if @frequency is 0
		
		# Get current ticks.
		if @async
			now = (Timing.TimingService.elapsed() - @last_) * 1000
			@last_ = Timing.TimingService.elapsed()
		else
			now = Timing.TimingService.tickElapsed() * 1000

		# The number of milliseconds since last invocation.
		since = 0

		# The number of ticks since last invocation.
		ticks = 0

		# At least one tick?
		if (since = (now + @tickRemainder)) >= @frequency
			
			# If there's been at least one tick, return the number of ticks
			# that occured, and update the current marker to calculate the
			# delta next time.
			ticks = Math.floor since / @frequency

		# Keep the remainder of a tick that's passed.
		@tickRemainder = since - ticks * @frequency
		
		for i in [0...ticks]
			@emit 'tick'
		
		return
