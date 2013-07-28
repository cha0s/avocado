
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = class
	
	mixins = [
		Property 'direction', 0
		Property 'position', [0, 0]
		EventEmitter
	]
	
	constructor: ->
		
		mixin.call this for mixin in mixins
		
		@_shapeList = []
		
	Mixin.apply null, [@::].concat mixins
	
	add: (shape) ->
		
		@_shapeList.push shape
		
	aabb: (translated = true) ->
		
		return [0, 0, 0, 0] if @_shapeList.length is 0
		
		min = [Infinity, Infinity]
		max = [-Infinity, -Infinity]
		
		for shape in @_shapeList
			
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
	
		@_shapeList = []
		
		for shape in O.shapes
			ShapeType = require "Physics/#{shape.type}"
			@add (new ShapeType()).fromObject shape
			
		return
		
	intersects: (shapeList) ->
		
		return false if @_shapeList.length is 0
		
		return false unless Rectangle.intersects(
			@aabb()
			shapeList.aabb()
		)
		
		for shape in @_shapeList
			
			for otherShape in shapeList._shapeList
				
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
					
					return true

		false
		
	render: (destination, camera) ->
		
		destination.drawLineBox(
			Rectangle.translated(
				@aabb()
				Vector.scale camera, -1
			)
			255, 0, 255, .25
		)
		
		for shape in @_shapeList
			
			destination.drawLineBox(
				Rectangle.translated(
					shape.aabb @direction()
					Vector.sub @position(), camera
				)
				255, 255, 0, .25
			)
			
			shape.render(
				destination
				@direction()
				Vector.sub @position(), camera
			)
		
	removeAtIndex: (index) ->
		
		@_shapeList[index].off 'aabbChanged'
		@_shapeList.splice index, 1
		
	toJSON: ->
		
		shapes: shape.toJSON() for shape in @shapeList
