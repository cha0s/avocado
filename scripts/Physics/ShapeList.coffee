
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
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
		PrivateScope.call @, Private, 'shapeListScope'
		
	Mixin.apply null, [@::].concat mixins

	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'shapeListScope'
	)
	
	forwardCallToPrivate 'aabb'
	
	forwardCallToPrivate 'add'
	
	forwardCallToPrivate 'fromObject'
	
	forwardCallToPrivate 'intersects'
	
	forwardCallToPrivate 'removeAtIndex'
	
	forwardCallToPrivate 'render'
	
	forwardCallToPrivate 'toJSON'
	
	Private = class
		
		constructor: ->
			
			@shapeList = []
		
		add: (shape) ->
			
			@shapeList.push shape
			
		aabb: (translated = true) ->
			
			_public = @public()
			
			min = [Infinity, Infinity]
			max = [-Infinity, -Infinity]
			
			for shape in @shapeList
				
				aabb = shape.aabb _public.direction()
				
				min[0] = Math.min min[0], aabb[0]
				min[1] = Math.min min[1], aabb[1]
				max[0] = Math.max max[0], aabb[0] + aabb[2]
				max[1] = Math.max max[1], aabb[1] + aabb[3]
				
			Rectangle.translated(
				[min[0], min[1], max[0] - min[0], max[1] - min[1]]
				if translated then _public.position() else [0, 0]
			)
		
		fromObject: (O) ->
		
			@shapeList = []
			
			for shape in O.shapes
				ShapeType = require "Physics/#{shape.type}"
				@add (new ShapeType()).fromObject shape
				
			return
			
		intersects: (shapeList) ->
			
			_public	= @public()
			_otherPrivate = shapeList.shapeListScope Private
			
			return false unless Rectangle.intersects(
				_public.aabb()
				shapeList.aabb()
			)
			
			for shape in @shapeList
				
				for otherShape in _otherPrivate.shapeList
					
					if Rectangle.intersects(
						Rectangle.translated(
							shape.aabb _public.direction()
							_public.position()
						)
						Rectangle.translated(
							otherShape.aabb shapeList.direction()
							shapeList.position()
						)
					
					)
						
						return true

			false
			
		render: (destination, camera) ->
			
			_public = @public()
			
			destination.drawLineBox(
				Rectangle.translated(
					_public.aabb()
					Vector.scale camera, -1
				)
				255, 0, 255, .25
			)
			
			for shape in @shapeList
				
				destination.drawLineBox(
					Rectangle.translated(
						shape.aabb _public.direction()
						Vector.sub _public.position(), camera
					)
					255, 255, 0, .25
				)
				
				shape.render(
					destination
					_public.direction()
					Vector.sub _public.position(), camera
				)
			
		removeAtIndex: (index) ->
			
			@shapeList[index].off 'aabbChanged'
			@shapeList.splice index, 1
			@calculateAabb()
			
		toJSON: ->
			
			shapes: shape.toJSON() for shape in @shapeList
