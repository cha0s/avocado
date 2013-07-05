
PrivateScope = require 'Utility/PrivateScope'
String = require 'Extension/String'

module.exports = Property = (key, defaultValue) ->
	
	_scope = "#{key}Scope"
	
	class
		
		constructor: ->
			PrivateScope.call @, Private, _scope
			
		@::[key] = ->
			
			_private = @[_scope] Private
			_private[key]
			
		@::[String.setterName key] = (value) ->
			
			_private = @[_scope] Private
			oldValue = _private[key]
			_private[key] = value
			@emit? "#{key}Changed", oldValue if oldValue isnt value
			
			return
			
		Private = class
			
			constructor: ->
				
				@[key] = defaultValue
