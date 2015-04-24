
Mixin = require '../index'
Transition = require './index'

module.exports = class TransitionVector

	constructor: (vector, Type = Transition) ->

		@[0] = vector[0]
		@[1] = vector[1]

		Mixin this, Type

	x: -> @[0]
	setX: (x) -> @[0] = x
	y: -> @[1]
	setY: (y) -> @[1] = y

TransitionVector.OutOfBand = TransitionVector

TransitionVector.InBand = class extends TransitionVector

	constructor: (vector) ->

		@[0] = vector[0]
		@[1] = vector[1]

		Mixin this, Transition.InBand

	x: -> @[0]
	setX: (x) -> @[0] = x
	y: -> @[1]
	setY: (y) -> @[1] = y

	vector: -> this

