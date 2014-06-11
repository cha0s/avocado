
module.exports = (type, implementation) ->
	
	try
		
		require "#{type}/#{implementation}"
	
	catch error
		
		unless "Cannot find module '#{type}/#{implementation}'" is error.message
			
			throw error
	
		if __implementSpi?
			
			__implementSpi implementation, type
			require "%#{type}"
		
		else
		
			throw new Error "No SPII found at #{type}/#{implementation}"
