
BehaviorItem = require './behaviorItem'
ObjectExt = require 'avo/extension/object'

module.exports = class Literal extends BehaviorItem
	
	constructor: ->
		
		@_literal = null
	
	fromObject: (O) ->
	
		@_literal = ObjectExt.deepCopy O
		
		this
	
	get: (context) -> @_literal
	set: (@_literal) ->
	
	toJSON: -> l: @_literal
