# SPI proxy and constant definitions.

# **Sample** is the representation for a sound effect.

Q = require 'Utility/Q'
Sample = require('Sound').Sample

# Sample playing constants.
# 
# * <code>Sample.LoopForever</code>: ***(default)*** Loops the sample
# forever.
Sample.LoopForever = -1

# Load a sample at the specified URI.
Sample.load = (uri) ->

	unless uri?
		return Q.reject new Error 'Attempted to load Sample with a null URI.'
	
	deferred = Q.defer()
	@['%load'] uri, deferred.makeNodeResolver()
	deferred.promise
	
# Play the sample for the specified number of loops.
Sample::play = (loops = 0) ->
	
	@['%play'] loops
