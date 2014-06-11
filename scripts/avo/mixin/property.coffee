
String = require 'avo/extension/string'

module.exports = Property = (key, defaultValue) ->
	
	class
		
		constructor: ->
			@["_#{key}"] = defaultValue
			
		@::[key] = -> @["_#{key}"]
			
		@::[String.setterName key] = (value) ->
			
			oldValue = @["_#{key}"]
			@["_#{key}"] = value
			@emit? "#{key}Changed", oldValue if oldValue isnt value
			
			return
