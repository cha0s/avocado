# The **Debug** module provides tools to help debug your
# application.
	
	Graphics = require 'Graphics'
	Timing = require 'Timing'
	
	m_isDebugging = false
	
	module.exports =
		
# Provide a global mechanism for the parts in the engine to adapt their
# behavior if we're debugging.
		
		isDebugging: -> m_isDebugging
		setIsDebugging: (isDebugging) -> m_isDebugging = isDebugging
		
# Halt execution until the callback returns true. Timeouts will still tick
# (so you can setTimeout while execution is halted), and input is polled
# (so you could halt until certain input is received). The CPU is relieved
# if we're on a platform where that makes sense.

		haltUntil: (f) ->
			
			until f()
				Timing.tickTimeouts()
				Graphics.graphicsService.pollEvents()
				Timing.timingService.sleep 100
				
			undefined
			
		errorMessage: (error) ->
			
			return "Unknown error" unless error?
			
			if error.stack?
				error.stack
			else if error.message?
				error.message
			else
				error.toString()
