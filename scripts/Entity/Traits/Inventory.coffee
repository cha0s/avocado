Entity = require 'Entity/Entity'
Trait = require 'Entity/Traits/Trait'
upon = require 'Utility/upon'

module.exports = class extends Trait

	defaults: ->
		
		meleeWeapon: ''
		rangeWeapon: ''
		inventory: {}
		
	initializeTrait: ->
		
		@inventory = {}
		
		inventoryPromises = for key, uri of @state.inventory
			
			((key, uri) =>
				Entity.load(uri).then (entity) =>
					@inventory[key] = entity
			) key, uri
		
		weaponPromises = for key in ['rangeWeapon', 'meleeWeapon']
			if @state[key] isnt ''
				Entity.load(@state[key]).then (entity) =>
					@[key] = entity
		
		upon.all(
			inventoryPromises.concat(weaponPromises)
		)
		
	values: ->
		
		rangeWeapon: -> @rangeWeapon
		
	actions: ->
		
		rangeAttack__: ->
			
			return unless @rangeWeapon?
			
			@rangeWeapon?.attack()
			
			increment: 1
			
			