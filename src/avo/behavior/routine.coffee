
Actions = require './actions'
BehaviorItem = require './behaviorItem'
Invocation = require './invocation'
Rules = require './rules'

Promise = require 'avo/vendor/bluebird'

module.exports = class Routine extends BehaviorItem

	constructor: ->

		@_actions = new Actions()
		@_rules = new Rules()

	fromObject: (O) ->

		Promise.allAsap [
			@_rules.fromObject O.rules ? []
			@_actions.fromObject O.actions ? []
		], => this

	invoke: (context) ->

		@_rules.invoke context
		@_actions.invoke context

	toJSON: ->

		rules: @_rules.toJSON()
		actions: @_actions.toJSON()
