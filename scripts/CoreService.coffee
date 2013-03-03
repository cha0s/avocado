# SPI proxy and constant definitions.

# Low-level API; writes a message to stderr (or equivalent, depending on
# platform).

Core = require 'Core'
upon = require 'Utility/upon'
 
Core.CoreService.writeStderr = Core.CoreService['%writeStderr']

# Low-level API; reads a resource into a string. Returns a promise to be
# resolved with the string containing the resource data. 
Core.CoreService.readResource = (uri) ->
	
	defer = upon.defer()
	
	Core.CoreService['%readResource'] uri, defer.resolve
	
	defer.promise

# Low-level API; reads a JSON resource. Returns a promise to be resolved with
# the parsed JSON object.
Core.CoreService.readJsonResource = (uri) ->
	
	defer = upon.defer()
	
	@readResource(uri).then (resource) -> defer.resolve JSON.parse resource
	
	defer.promise
