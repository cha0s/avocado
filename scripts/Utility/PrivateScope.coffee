
_ = require 'Utility/underscore'
String = require 'Extension/String'

module.exports = PrivateScope = (Class, method = 'getScope') ->
	
	oPrivate = new Class @
	@[method] = oPrivate['public'] = _.bind(
		(owner, Class) -> if owner?.constructor is Class then owner else @
		@, oPrivate
	)
	oPrivate

PrivateScope.forwardCall = (
	owner
	call
	Private
	method = 'getScope'
) ->
	owner[call] = ->
		_private = @[method] Private()
		_private[call].apply _private, arguments

PrivateScope.forwardProperty = (
	owner
	property
	Private
	method = 'getScope'
) ->
	@forwardCall owner, property, Private, method
	@forwardCall owner, String.setterName(property), Private, method
