# The **Debug/Execution** module provides tools to help debug your
# application.

Graphics = require 'Graphics'
Timing = require 'Timing'

module.exports =
	
	# Halt execution until the callback returns true. Timeouts will still tick
	# (so you can setTimeout while execution is halted), and input is polled
	# (so you could halt until certain input is received).
	haltUntil: (f) ->
		
		until f()
			
			# Turn down resolution to 1/10 second, to save CPU.
			Timing.timingService.sleep 100
			
			Timing.tickTimeouts()
			Graphics.graphicsService.pollEvents()
			
		undefined
