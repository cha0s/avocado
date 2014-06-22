
Promise = require 'avo/vendor/bluebird'

config = require 'avo/config'

resourceCache = {}
exports.readResource = (uri) ->
	
	qualifiedUri = "#{config.get 'fs:resourcePath'}#{uri}"
	
	new Promise (resolve, reject) ->
	
		if resourceCache[qualifiedUri]?
			
			resolve resourceCache[qualifiedUri]
			
		else 
			
			request = new window.XMLHttpRequest()
			request.open 'GET', qualifiedUri
			request.onreadystatechange = ->
				
				if request.readyState is 4
					
					switch request.status
						
						when 0, 200
						
							resolve resourceCache[qualifiedUri] = request.responseText
						
						else
						
							reject new Error "Couldn't load resource: #{qualifiedUri}"
			
			request.send()

# Reads a JSON resource. Returns a promise to be resolved with the parsed
# JSON object.
exports.readJsonResource = (uri) ->
	
	@readResource(uri).then (O) ->
		
		try
			
			JSON.parse O
		
		catch error
			
			error.message = "Error parsing #{
				"#{config.get 'fs:resourcePath'}#{uri}"
			} -> #{
				error.message
			}"
			
			throw error