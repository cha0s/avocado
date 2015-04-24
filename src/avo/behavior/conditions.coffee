
Collection = require './collection'

module.exports = class Conditions extends Collection 'conditions'

	get: (context) ->

		result = true

		index = 0
		while result and index < @_conditions.length
			result = result and @_conditions[index].get context
			index += 1

		result
