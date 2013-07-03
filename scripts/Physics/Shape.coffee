
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'
VectorMixin = require 'Mixin/Vector'

module.exports = class
	
	mixins = [
		VectorMixin 'position', 'x', 'y'
		Property 'type', 'Shape'
		EventEmitter
	]
	
	constructor: ->
	
		mixin.call this for mixin in mixins
	
	aabb: (position) -> [0, 0, 0, 0]
	
	fromObject: (O) ->
		
		@setPosition O.position
		
		this
	
	toJSON: ->
		
		type: @type()
		position: @position()
	
	Mixin.apply null, [@::].concat mixins
