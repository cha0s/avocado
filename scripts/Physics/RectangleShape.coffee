
FunctionExt = require 'Extension/Function'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
Shape = require 'Physics/Shape'
Vector = require 'Extension/Vector'
VectorMixin = require 'Mixin/Vector'

module.exports = class extends Shape
	
	mixins = [
		VectorMixin 'size', 'width', 'height'
	]
	
	constructor: ->
		super
		
		mixin.call this for mixin in mixins
		
		@setType 'RectangleShape'
		
	aabb: (direction) ->
		
		position = Vector.projected @position(), direction
		size = Vector.projected @size(), direction, true
		
		[
			position[0] - size[0] / 2
			position[1] - size[1] / 2
			size[0]
			size[1]
		]
		
	fromObject: (O) ->
		super
		
		@setSize O.size
		
		this
	
	render: (destination, direction, position) ->
		
		destination.drawFilledBox(
			Rectangle.translated(
				@aabb direction
				position
			)
			255, 255, 255, .25
		)
	
	toJSON: ->
		
		O = super
		
		O.size = @size()
		
		O
	
	FunctionExt.fastApply Mixin, [@::].concat mixins
