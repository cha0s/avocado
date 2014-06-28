
Promise = require 'avo/vendor/bluebird'

config = require 'avo/config'

readUri = (uri) ->

	new Promise (resolve, reject) ->
	
		request = new window.XMLHttpRequest()
		request.open 'GET', uri
		request.onreadystatechange = ->
			
			if request.readyState is 4
				
				switch request.status
					
					# Work around for old node-webkit behavior.
					# See: https://github.com/rogerwang/node-webkit/commit/08c6ce5ff3fcf1b4df0aca1e717bb80d617214a2
					
					when 0, 200
						
						if request.responseText
							resolve request.responseText
						else
							reject	new Error "Couldn't load #{uri}"
					
					else
					
						reject new Error "Couldn't load #{uri}"
		
		request.send()

resourceCache = {}
exports.readResource = (uri) ->
	
	qualifiedUri = "#{config.get 'fs:resourcePath'}#{uri}"
	
	new Promise (resolve, reject) ->
	
		if resourceCache[qualifiedUri]?
			
			resolve resourceCache[qualifiedUri]
			
		else
			
			readUri(qualifiedUri).then (text) ->
			
				resolve resourceCache[qualifiedUri] = text
	
uiCache = {}
exports.readUi = (uri) ->
	
	qualifiedUri = "#{config.get 'fs:uiPath'}#{uri}"
	
	new Promise (resolve, reject) ->
	
		if uiCache[qualifiedUri]?
			
			resolve uiCache[qualifiedUri]
			
		else
			
			readUri(qualifiedUri).then (text) ->
			
				resolve uiCache[qualifiedUri] = text
	
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
