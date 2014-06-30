
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

FunctionExt = require 'avo/extension/function'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'
Vertice = require 'avo/extension/vertice'

color = require 'avo/graphics/color'
Primitives = require 'avo/graphics/primitives'

Shape = require './index'

module.exports = class ShapePolygon extends Shape
	
	constructor: ->
		super
		
		@_vertices = []
		@_translatedVertices = []
		
		@setType 'polygon'
		
		@on [
			'parentOriginChanged', 'parentRotationChanged', 'parentScaleChanged'
			'originChanged', 'rotationChanged', 'scaleChanged', 'verticesChanged'
		], =>
			
			origin = Vector.add @parentOrigin(), @origin()
			rotation = @parentRotation() + @rotation()
			scale = @parentScale() * @scale()
			
			@_translatedVertices = @_vertices.map (vertice) =>
				
				Vertice.translate vertice, origin, rotation, scale

			length = @_translatedVertices.length
			
			@_primitives.clear()
			
			@_primitives.drawCircle(
				origin, 2
				Primitives.LineStyle color 0, 0, 255
			)
				
			@_primitives.drawRectangle(
				@aabb()
				Primitives.LineStyle color 255, 255, 0
			)
				
			@_primitives.drawLine(
				vertice, @_translatedVertices[(i + 1) % length]
				Primitives.LineStyle color 255, 255, 255
			) for vertice, i in @_translatedVertices
			
			@emit 'aabbChanged'

	aabb: ->
		return [0, 0, 0, 0] if @_vertices.length is 0
		
		min = [Infinity, Infinity]
		max = [-Infinity, -Infinity]
		
		# TODO: Translate vertices
		
		for vertice in @_translatedVertices
			
			min[0] = Math.min min[0], vertice[0]
			min[1] = Math.min min[1], vertice[1]
			max[0] = Math.max max[0], vertice[0]
			max[1] = Math.max max[1], vertice[1]
			
		[
			min[0], min[1]
			max[0] - min[0], max[1] - min[1]
		]
		
	fromObject: (O) ->
		super
		
		@setVertices O.vertices
		
		this
	
	setVertices: (vertices) ->
		
		@_vertices = vertices.slice()
		
		@emit 'verticesChanged'
		
		return
	
	toJSON: ->
		
		O = super
		
		O.vertices = @_vertices.slice()
		
		O
