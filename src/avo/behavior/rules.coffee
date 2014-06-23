
Collection = require './collection'

module.exports = class Rules extends Collection 'rules'

	invoke: (context) -> rule.invoke context for rule in @_rules
