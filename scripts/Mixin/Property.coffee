
String = require 'Extension/String'

module.exports = Property = (key, defaultValue) ->
	
	_key = "_#{key}"
	
	class
			
		@::[_key] = null
		
		constructor: -> @[_key] = defaultValue
			
		@::[key] = -> @[_key]
		@::[String.setterName key] = (value) ->
			oldValue = @[_key]
			@[_key] = value
			@emit? "#{key}Changed" if value isnt oldValue
		