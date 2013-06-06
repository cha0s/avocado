
String = require 'Extension/String'

module.exports = (key, value) -> class
		
	@::["_#{key}"] = {}
	
	constructor: ->
		
		@["_#{key}"] = value
		
	@::[key] = -> @["_#{key}"]
	@::[String.setterName key] = (value) -> @["_#{key}"] = value
	