
String = require 'Extension/String'

module.exports = Property = (key, value) ->
	
	_key = "_#{key}"
	
	class
			
		@::[_key] = null
		
		constructor: -> @[_key] = value
			
		@::[key] = -> @[_key]
		@::[String.setterName key] = (value) -> @[_key] = value
		