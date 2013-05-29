
Trait = require 'Entity/Traits/Trait'

module.exports = class extends Trait
	
	stateDefaults: ->
	
	resetTrait: ->
		
		@state.baz = 420
