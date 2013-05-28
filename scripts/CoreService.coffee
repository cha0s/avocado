# SPI proxy and constant definitions.

# Low-level API; writes a message to stderr (or equivalent, depending on
# platform).

Core = require 'Core'
Q = require 'Utility/Q'
 
Core.CoreService.writeStderr = Core.CoreService['%writeStderr']

# Low-level API; reads a resource into a string. Returns a promise to be
# resolved with the string containing the resource data. 
resourceCache = {}
Core.CoreService.readResource = (uri, useCache = true) ->
	
	return resourceCache[uri] if useCache and resourceCache[uri]?
	
	deferred = Q.defer()
	
	resourceCache[uri] = deferred.promise if useCache
		
	Core.CoreService['%readResource'] uri, deferred.makeNodeResolver()
	
	deferred.promise

# Low-level API; reads a JSON resource. Returns a promise to be resolved with
# the parsed JSON object.
jsonResourceCache = {}
Core.CoreService.readJsonResource = (uri, useCache = true) ->
	
	return jsonResourceCache[uri] if useCache and jsonResourceCache[uri]?
	
	promise = @readResource(uri, useCache).then(
		(O) -> JSON.parse O
	)

	jsonResourceCache[uri] = promise if useCache
