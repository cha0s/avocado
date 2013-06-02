# **Ticker** allows you to keep track of how many discrete ticks have
# passed. Ticks are measured in milliseconds.

TimingService = require('Timing').TimingService

module.exports = Ticker = class

	# Initialize a ticker to count a tick every *frequency* milliseconds.
	constructor: (@frequency, @async = true) ->
		
		# Keep the remainder counted towards the next tick.
		@tickRemainder = 0
		
		if @async
			@last_ = TimingService.elapsed()
		
	# Deep copy a ticker.
	deepCopy: ->
		
		ticker = new Ticker()
		
		ticker.tickRemainder = @tickRemainder
		ticker.frequency = @frequency
		
		if ticker.async = @async
			ticker.last_ = @last_
	
	# Reset a ticker, so it will be *@frequency* milliseconds until the next
	# tick.
	reset: ->
		
		if @async
			@last_ = TimingService.elapsed()
		
		@tickRemainder = 0
	
	setFrequency: (@frequency) ->
	
	# Count the number of ticks passed since the last invocation.
	ticks: ->
		return 0 if @frequency is 0
		
		# Get current ticks.
		if @async
			now = (TimingService.elapsed() - @last_) * 1000
			@last_ = TimingService.elapsed()
		else
			now = TimingService.tickElapsed() * 1000

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

		ticks
