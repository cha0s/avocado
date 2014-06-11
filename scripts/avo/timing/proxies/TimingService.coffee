# SPI proxy and constant definitions.

# **TimingService** provides CPU sleep (if the platform supports it), and
# timeouts/intervals.

exports.proxy = (Timing) ->

	# Delay execution by a given number of milliseconds.
	Timing.TimingService::sleep = (ms) ->
		return unless ms?
		
		@['%sleep'] ms
	
	Timing.TimingService.current = -> Date.now()
	
	# Total elapsed time.
	elapsed = 0
	Timing.TimingService.elapsed = -> elapsed
	Timing.TimingService.setElapsed = (e) -> elapsed = e
	
	# Time elapsed per engine tick.
	tickElapsed = 0
	Timing.TimingService.tickElapsed = -> tickElapsed
	Timing.TimingService.setTickElapsed = (e) -> tickElapsed = e
