
_ = require 'Utility/underscore'

module.exports = (Class, method = 'getScope') ->
	
	oPrivate = new Class @
	@[method] = oPrivate['public'] = _.bind(
		(owner, Class) -> if owner?.constructor is Class then owner else @
		@, oPrivate
	)
	oPrivate
