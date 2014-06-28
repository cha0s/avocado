
Entity = require 'avo/entity'

Trait = require './trait'

module.exports = class Parent extends Trait
	
	stateDefaults: ->
		
		children: []
	
	constructor: ->
		super
		
		@_children = []
		
	initialize: ->
		
		for {uri, traitExtensions} in @state.children
			
			Entity.load(uri, traitExtensions).then (child) =>
				
				child.setParent @entity
				@_children.push child
				
	values: ->
		
		children: -> @_children
		
