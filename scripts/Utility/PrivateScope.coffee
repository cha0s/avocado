
_ = require 'Utility/underscore'

module.exports = (Class) ->
	
	oPrivate = new Class @
	@getScope = oPrivate.getScope = _.bind(
		(owner, Class) -> if owner?.constructor is Class then owner else @
		@, oPrivate
	)
	oPrivate
