# SPI proxy and constant definitions.

# Low-level API; writes a message to stderr (or equivalent, depending on
# platform).

Core = require 'Core'
Q = require 'Utility/Q'
 
Core.CoreService.writeStderr = Core.CoreService['%writeStderr']

# Low-level API; reads a resource into a string. Returns a promise to be
# resolved with the string containing the resource data. 
Core.CoreService.readResource = (uri) ->
	
	deferred = Q.defer()
	
	Core.CoreService['%readResource'] uri, deferred.makeNodeResolver()
	
	deferred.promise

# Low-level API; reads a JSON resource. Returns a promise to be resolved with
# the parsed JSON object.
Core.CoreService.readJsonResource = (uri) ->
	
	@readResource(uri).then(
		(resource) -> JSON.parse resource
	)
