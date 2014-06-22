
i8n = require 'avo/vendor/inflection'

module.exports = (type, implementation) ->
	
	try
		
		require "avo/#{type}/#{implementation}"
	
	catch error
		
		unless "Cannot find module '#{type}/#{implementation}'" is error.message
			
			console.log error.stack
			throw error
	
		spii = require "__#{type}"
		
		if __implementSpi?
			
			__implementSpi implementation, type
			spii
		
		else
			
			Service = spii[i8n.camelize "#{type}_service"]
			unless Service.implementSpi?
				throw new Error "No SPII found at #{type}/#{implementation}"
			
			Service.implementSpi implementation
			spii
