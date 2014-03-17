
EventEmitter = require 'Mixin/EventEmitter'
FunctionExt = require 'Extension/Function'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'
VectorMixin = require 'Mixin/Vector'

module.exports = class
	
	mixins = [
		VectorMixin 'position', 'x', 'y'
		Property 'type', 'Shape'
		Property 'density', 0
		Property 'isHarmful', false
		EventEmitter
	]
	
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	constructor: ->
	
		mixin.call this for mixin in mixins
	
	aabb: (position) -> [0, 0, 0, 0]
	
	fromObject: (O) ->
		
		@setPosition O.position if O.position?
		@setIsHarmful O.isHarmful if O.isHarmful?
		@setMass O.mass if O.mass?
		
		this
	
	toJSON: ->
		
		type: @type()
		position: @position()
