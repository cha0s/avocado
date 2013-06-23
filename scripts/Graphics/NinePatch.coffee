
Graphics = require 'Graphics'

CoreService = require('Core').CoreService
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = NinePatch = class
	
	@load = (uri) ->
		CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			ninePatch = new NinePatch()
			ninePatch.fromObject O
	
	constructor: ->
		
		@_middleRect = [0, 0, 0, 0]
	
	fromObject: (O) ->
	
		@["_#{i}"] = O[i] for i of O
		
		O.imageUri = O.uri.replace '.ninePatch.json', '.png' if not O.imageUri?
		
		Graphics.Image.load(O.imageUri).then (image) =>
			
			@setImage image
			
			this
	
	toJSON: ->
		
		imageUri: @_image.uri() if @_image.uri() isnt @_uri.replace '.ninePatch.json', '.png'
		middleRect: @_middleRect
	
	setImage: (@_image) -> @_calculateRects()
		
	_calculateRects: ->
		
		position = Rectangle.position @_middleRect
		size = Rectangle.size @_middleRect
		
		middles = Vector.add position, size
		ends = Vector.sub @_image.size(), middles
		
		@_rects = [
			Rectangle.compose [0, 0], position
			Rectangle.compose [position[0], 0], [size[0], position[1]]
			Rectangle.compose [middles[0], 0], [ends[0], position[1]]
			Rectangle.compose [0, position[1]], [position[0], size[1]]
			@_middleRect
			Rectangle.compose [middles[0], position[1]], [ends[0], size[1]]
			Rectangle.compose [0, middles[1]], [position[0], ends[1]]
			Rectangle.compose [position[0], middles[1]], [size[0], ends[1]]
			Rectangle.compose middles, ends
		]
	
	render: (
		rect
		destination
		alpha = 1
	) ->
		
		rect = Rectangle.round rect
		
		return if Rectangle.isNull rect
		
		rect = Rectangle.compose(
			Rectangle.position rect
			Vector.max @_image.size(), Rectangle.size rect
		)
		
		edgeSize = [
			@_rects[0][2] + @_rects[2][2]
			@_rects[0][3] + @_rects[6][3]
		]
		
		middleSize = Vector.sub(
			Rectangle.size rect
			edgeSize
		)
		
		middleUnits = Vector.floor Vector.div middleSize, Rectangle.size @_middleRect
		middleRemainder = Vector.mod middleSize, Rectangle.size @_middleRect
		
		sprite = new Graphics.Sprite()
		sprite.setSource @_image
		sprite.setAlpha alpha
		
		renderRemainder = (pieceRect, orientation, fn) ->
		
			return unless middleRemainder[orientation] > 0
				
			partialRect = Rectangle.copy pieceRect
			
			index = if orientation is 0 then 2 else 3
			partialRect[index] = middleRemainder[orientation]
			
			fn partialRect
		
		(renderSides = =>
		
			renderSide = (orientation, pieceRect, position, step) =>
				
				for [0...middleUnits[orientation]]
					
					sprite.setPosition Vector.add position, Rectangle.position rect
					sprite.setSourceRectangle pieceRect
					sprite.renderTo destination
					
					position[orientation] += step
				
				renderRemainder pieceRect, orientation, (partialRect) =>
				
					sprite.setPosition Vector.add position, Rectangle.position rect
					sprite.setSourceRectangle partialRect
					sprite.renderTo destination
					
				return
				
			renderHorizontal = renderSide.bind this, 0
			renderVertical = renderSide.bind this, 1
			
			renderHorizontal(
				@_rects[1]
				Rectangle.position @_rects[1]
				@_rects[1][2]
			)
			
			renderHorizontal(
				@_rects[7]
				[@_rects[7][0], rect[3] - @_rects[7][3]]
				@_rects[7][2]
			)
			
			renderVertical(
				@_rects[3]
				Rectangle.position @_rects[3]
				@_rects[3][3]
			)
			
			renderVertical(
				@_rects[5]
				[rect[2] - @_rects[5][2], @_rects[5][1]]
				@_rects[5][3]
			)
			
		)()
		
		(renderMiddle = =>
		
			position = Rectangle.position @_middleRect
			size = Rectangle.size @_middleRect
	
			renderMiddleRow = (pieceRect) =>
			
				for [0...middleUnits[0]]
				
					sprite.setPosition Vector.add position, Rectangle.position rect
					sprite.setSourceRectangle pieceRect
					sprite.renderTo destination
					
					position[0] += size[0]
					
				renderRemainder pieceRect, 0, (partialRect) =>
					
					sprite.setPosition Vector.add position, Rectangle.position rect
					sprite.setSourceRectangle partialRect
					sprite.renderTo destination
					
			for [0...middleUnits[1]]
				
				renderMiddleRow @_middleRect
				
				position[0] -= middleUnits[0] * size[0]
				position[1] += size[1]
				
			renderRemainder @_middleRect, 1, (partialRect) =>
				
				renderMiddleRow partialRect
				
		)()
		
		(renderCorners = =>
			
			middles = [rect[0] + rect[2], rect[1] + rect[3]]
			
			renderCorner = (position, pieceRect) =>
				
				sprite.setPosition position
				sprite.setSourceRectangle pieceRect
				sprite.renderTo destination
			
			renderCorner(
				Rectangle.position rect
				@_rects[0]
			)
				
			renderCorner(
				[middles[0] - @_rects[2][2], rect[1]]
				@_rects[2]
			)
				
			renderCorner(
				[rect[0], middles[1] - @_rects[6][3]]
				@_rects[6]
			)
			
			renderCorner(
				Vector.sub middles, Rectangle.size @_rects[8]
				@_rects[8]
			)
			
		)()
		
		undefined
