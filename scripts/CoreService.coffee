# SPI proxy and constant definitions.

# Low-level API; writes a message to stderr (or equivalent, depending on
# platform).

Core = require 'Core'
Debug = require 'Debug'
Promise = require 'Utility/bluebird'
 
Core.CoreService.writeStderr = Core.CoreService['%writeStderr']

# Low-level API; reads a resource into a string. Returns a promise to be
# resolved with the string containing the resource data. 
resourceCache = {}
Core.CoreService.readResource = (uri, useCache = true) ->
	
	return resourceCache[uri] if useCache and resourceCache[uri]?
	
	deferred = Promise.defer()
	
	resourceCache[uri] = deferred.promise if useCache
		
	Core.CoreService['%readResource'] uri, deferred.callback
	
	deferred.promise

# Low-level API; reads a JSON resource. Returns a promise to be resolved with
# the parsed JSON object.
jsonResourceCache = {}
Core.CoreService.readJsonResource = (uri, resourceCache = true, jsonCache = false) ->
	
	return jsonResourceCache[uri] if jsonCache and jsonResourceCache[uri]?
	
	promise = @readResource(uri, resourceCache).then (O) ->
		
		try
			JSON.parse O
		catch error
			throw new Error "Error parsing #{
				uri
			}: #{
				Debug.errorMessage error
			}"
		

	jsonResourceCache[uri] = promise if jsonCache
	
	promise
