
Mixin = require '../index'
Transition = require './index'

module.exports = class TransitionValue

	constructor: (value, key = 'value', Type = Transition) ->

		@["_#{key}"] = value

		@[key] = -> @["_#{key}"]
		@[String.setterName key] = (value) -> @["_#{key}"] = value

		Mixin this, Type

TransitionValue.OutOfBand = TransitionValue

TransitionValue.InBand = class extends TransitionValue

	constructor: (value, key = 'value') ->

		@["_#{key}"] = value

		@[key] = -> @["_#{key}"]
		@[String.setterName key] = (value) -> @["_#{key}"] = value

		Mixin this, Transition.InBand

