
Promise = require 'avo/vendor/bluebird'

BehaviorItem = require './behaviorItem'
Routine = require './routine'

module.exports = class Routines extends BehaviorItem

	constructor: ->

		@_index = null
		@_routines = {}

	fromObject: (O) ->

		Promise.allAsap(

			for index, routine of O
				@_index = index unless @_index?

				@_routines[index] = new Routine()
				@_routines[index].fromObject routine

			=> this
		)

	index: -> @_index
	setIndex: (@_index) ->

	routine: (index = @_index) -> @_routines[index]

	toJSON: ->

		O = routines: {}
		for index, routine of @_routines
			O.routines[index] = routine.toJSON()
		O
