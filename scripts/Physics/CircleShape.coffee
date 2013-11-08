
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Shape = require 'Physics/Shape'
Vector = require 'Extension/Vector'

module.exports = class extends Shape
	
	mixins = [
		Property 'radius', 0
		Property 'startAngle', 0
		Property 'endAngle', Math.PI * 2
	]
	
	constructor: ->
		super
		
		mixin.call this for mixin in mixins
		
		@setType 'CircleShape'
	
	aabb: (direction) ->
		
		position = Vector.projected @position(), direction
		radius = @radius()
		
		[
			position[0] - radius
			position[1] - radius
			radius * 2
			radius * 2
		]
		
	fromObject: (O) ->
		super
		
		@setRadius O.radius if O.radius?
		@setStartAngle O.startAngle if O.startAngle?
		@setEndAngle O.endAngle if O.endAngle?
		
		this
	
	render: (destination, direction, position) ->
		
		destination.drawCircle(
			Vector.add position, Vector.projected @position(), direction
			@radius()
			255, 255, 255, .5
		)
	
	toJSON: ->
		
		O = super
		
		O.radius = @radius()
		O.startAngle = @startAngle()
		O.endAngle = @endAngle()
		
		O
	
	Mixin.apply null, [@::].concat mixins
