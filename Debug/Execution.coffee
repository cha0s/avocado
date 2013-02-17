Graphics = require 'Graphics'
Timing = require 'Timing'

module.exports =
	
	haltUntil: (f) ->
		
		until f()
			
			Timing.timingService.sleep 100
			
			Timing.tickTimeouts()
			
			Graphics.graphicsService.pollEvents()
			
		undefined
