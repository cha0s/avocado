
Actions = require './actions'
BehaviorItem = require './behaviorItem'
Condition = require './condition'

Promise = require 'avo/vendor/bluebird'

module.exports = class Rule extends BehaviorItem

	constructor: ->

		@_condition = new Condition()
		@_actions = new Actions()

	fromObject: (O) ->

		Promise.allAsap [
			@_condition.fromObject O.condition
			@_actions.fromObject O.actions
		], => this

	action: (index) -> @_actions.action index

	actions: -> @_actions

	condition: -> @_condition

	invoke: (context) ->
		return unless @_condition.get context

		@_actions.invokeImmediately context

	toJSON: ->

		condition: @_condition.toJSON()
		actions: @_actions.toJSON()
