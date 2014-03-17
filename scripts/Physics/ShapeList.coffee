
EventEmitter = require 'Mixin/EventEmitter'
FunctionExt = require 'Extension/Function'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = class ShapeList
	
	mixins = [
		Property 'direction', 0
		Property 'position', [0, 0]
		EventEmitter
	]
	
	constructor: ->
		
		mixin.call this for mixin in mixins
		
		@_shapes = []
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	addShape: (shape) -> @_shapes.push shape
		
	aabb: (translated = true) ->
		
		return [0, 0, 0, 0] if @_shapes.length is 0
		
		min = [Infinity, Infinity]
		max = [-Infinity, -Infinity]
		
		for shape in @_shapes
			
			aabb = shape.aabb @direction()
			
			min[0] = Math.min min[0], aabb[0]
			min[1] = Math.min min[1], aabb[1]
			max[0] = Math.max max[0], aabb[0] + aabb[2]
			max[1] = Math.max max[1], aabb[1] + aabb[3]
			
		Rectangle.translated(
			[min[0], min[1], max[0] - min[0], max[1] - min[1]]
			if translated then @position() else [0, 0]
		)
	
	fromObject: (O) ->
	
		@_shapes = []
		
		for shape in O.shapes
			ShapeType = require "Physics/#{shape.type}"
			@addShape (new ShapeType()).fromObject shape
			
		return
		
	intersects: (shapeList) ->
		
		return false if @_shapes.length is 0
		
		return false unless Rectangle.intersects(
			@aabb()
			shapeList.aabb()
		)
		
		for shape in @_shapes
			
			for otherShape in shapeList._shapes
				
				if Rectangle.intersects(
					Rectangle.translated(
						shape.aabb @direction()
						@position()
					)
					Rectangle.translated(
						otherShape.aabb shapeList.direction()
						shapeList.position()
					)
				
				)
					
					return (
						self: shape
						other: otherShape
					)

		false
		
	render: (destination, camera) ->
		
		destination.drawLineBox(
			Rectangle.translated(
				@aabb()
				Vector.scale camera, -1
			)
			255, 0, 255, .25
		)
		
		for shape in @_shapes
			
			destination.drawLineBox(
				Rectangle.translated(
					shape.aabb @direction()
					Vector.sub @position(), camera
				)
				255, 255, 0, .5
			)
			
			shape.render(
				destination
				@direction()
				Vector.sub @position(), camera
			)
		
	removeAtIndex: (index) ->
		
		@_shapes[index].off 'aabbChanged'
		@_shapes.splice index, 1
		
	shapes: -> @_shapes
		
	toJSON: ->
		
		shapes: shape.toJSON() for shape in @_shapes
