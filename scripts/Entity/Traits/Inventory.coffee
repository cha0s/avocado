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
		
		fulfillInventory = (key) => (entity) => @inventory[key] = entity
		inventoryPromises = for key, uri of @state.inventory
			Entity.load(uri).then fulfillInventory key
		
		fulfillWeapon = (key) => (entity) => @[key] = entity
		weaponPromises = for key in ['rangeWeapon', 'meleeWeapon']
			if @state[key] isnt ''
				Entity.load(@state[key]).then fulfillWeapon key
		
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
			
			