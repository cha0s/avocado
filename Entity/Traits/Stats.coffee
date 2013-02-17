Trait = require 'Entity/Traits/Trait'

module.exports = class extends Trait

	defaults: ->
		
		hp: 1
		stability: 0
		
		attack: 0
		defense: 0
		
	actions: ->
	
	values: ->
		
		isDead: -> @state.hp <= 0
		
		hp: -> @state.hp
		
		stability: -> @state.stability
	
	
