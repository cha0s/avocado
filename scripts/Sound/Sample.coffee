# SPI proxy and constant definitions.

# **Sample** is the representation for a sound effect.

Sample = require('Sound').Sample
upon = require 'Utility/upon'

# Sample playing constants.
# 
# * <code>Sample.LoopForever</code>: ***(default)*** Loops the sample
# forever.
Sample.LoopForever = -1

# Load a sample at the specified URI.
Sample.load = (uri) ->

	defer = upon.defer()
	
	unless uri?
		
		defer.reject new Error 'Attempted to load Sample with a null URI.'
		return defer.promise
	
	@['%load'] uri, (error, sample) ->
		
		return defer.reject error if error?
		
		defer.resolve sample
	
	defer.promise
	
# Play the sample for the specified number of loops.
Sample::play = (loops = 0) ->
	
	@['%play'] loops
