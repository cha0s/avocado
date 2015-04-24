
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

	actions: ->

		addChild: (child) ->

			@_children.push child
			child.setParent @entity

			@entity.emit 'childrenChanged'

		removeChild: (child) ->

			return if -1 is (index = @_children.indexOf child)

			@_children.splice index, 1

			@entity.emit 'childrenChanged'

	values: ->

		children: -> @_children

		hasChild: (child) -> -1 isnt @_children.indexOf child

	hooks: ->

		takesHarmFrom: (entity) -> not @entity.hasChild entity
