
Collection = require './collection'

module.exports = class Conditions extends Collection 'conditions'

  check: (context) ->
    result = true

    index = 0
    while result and index < @_conditions.length
      result = result and @_conditions[index].check context
      index += 1

    result
