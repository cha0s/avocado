# **TileLayer** represents a 2D tile matrix. It is a glorified array of
# tile indices which index into a tileset.

_ = require 'Utility/underscore'
base64 = require 'Utility/base64'
DisplayCommand = require 'Graphics/DisplayCommand'
Graphics = require 'Graphics'
Image = require('Graphics').Image
Lzw = require 'Utility/Lzw'
Rectangle = require 'Extension/Rectangle'
upon = require 'Utility/upon'
Vector = require 'Extension/Vector'

module.exports = TileLayer = class
	
	constructor: (size = [0, 0]) ->
		
		# The tile index data.
		area = Vector.area size
		@tileIndices_ = if 0 is area
			null
		else
			0 for i in [0...area]
	
		# The size of the tile matrix.
		@size_ = Vector.copy size
		
	fromObject: (O) ->
		
		defer = upon.defer()
		
		@["#{i}_"] = O[i] for i of O
		
		@size_ = Vector.copy @size_
		
		@tileIndices_ = (0 for i in [0...Vector.area @size_]) unless @tileIndices_?
			
		defer.resolve()
			
		defer.promise
	
	toJSON: ->
		
		tileIndices = if 0 isnt Math.max.apply Math, @tileIndices_
			base64.toBase64 Lzw.compress @tileIndices_.toString()
		else
			null
			
		tileIndices: tileIndices
		size: @size_
		
	copy: ->
		
		layer = new TileLayer()
		layer.fromObject @toJSON()
		
		layer 
	
	# Resize the layer, losing as little information as possible.
	resize: (w, h) ->
		
		size = if w instanceof Array then w else [w, h]
		
		tileIndices = new Array size[0] * size[1]
		for y in [0...size[1]]
			for x in [0...size[0]]
				tileIndices[y * size[0] + x] = @tileIndex x, y
				
		@size_ = size
		@tileIndices_ = tileIndices
		
		this
	
	size: -> @size_
	
	height: -> @size_[1]
	width: -> @size_[0]
	
	# Calculate a tile index. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     calcTileIndex [10, 10]
	# * With width, height:
	#     calcTileIndex 10, 10
	# * With a tile index:
	#     calcTileIndex 28
	calcTileIndex: (x, y) ->
		
		return unless @tileIsValid x, y
		
		[x, y] = x if x instanceof Array
		
		if y? then @size_[0] * y + x else x
	
	# Retrieve a tile index. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     tileIndex [10, 10]
	# * With width, height:
	#     tileIndex 10, 10
	# * With a tile index:
	#     tileIndex 28
	tileIndex: (x, y) ->
	
		return 0 unless @tileIndices_?
		
		@tileIndices_[@calcTileIndex x, y] ? 0
	
	# Set a tile index. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     setTileIndex index, [10, 10]
	# * With width, height:
	#     setTileIndex index, 10, 10
	# * With a tile index:
	#     setTileIndex index, 28
	setTileIndex: (index, x, y) ->
	
		i = @calcTileIndex x, y
		
		return unless i?
		
		@tileIndices_[i] = index
	
	# Check whether a tile is valid. You can call this function in 3 ways:
	# 
	# * With a vector:
	#     tileIsValid [10, 10]
	# * With width, height:
	#     tileIsValid 10, 10
	# * With a tile index:
	#     tileIsValid 28
	tileIsValid: (x, y) ->
		
		[x, y] = x if x instanceof Array
		
		return false if x < 0
		
		if y?
		
			y >= 0 and x < @size_[0] and y < @size_[1]
			
		else
			
			if x? then x < @area() else false
	
	# Calculate the area of the tile layer.
	area: -> @size_[0] * @size_[1]
	
	setTileMatrix: (matrix, position) ->
	
		for row, y in matrix
			for index, x in row
				@setTileIndex index, position[0] + x, position[1] + y
	
	tileMatrix: (size, position) ->
		
		matrix = []
		
		for y in [0...size[1]]
			
			row = []
			matrix.push row
			
			for x in [0...size[0]]
				
				row.push @tileIndex position[0] + x, position[1] + y
				
		matrix
	
	fastRender: (
		tileset
		destination
	) ->
	
		tiles = tileset.tiles()
		image = tileset.image()
		
		destinationWidth = destination.width()
		tileSize = tileset.tileSize()
		
		position = [0, 0]
		
		i = 0
		
		y = 0
		while y++ < @size_[1]
			
			x = 0
			while x++ < @size_[0]
				
				index = @tileIndices_[i++]
				
				tileset.render(
					position
					destination
					index
				) if index
				
				position[0] += tileSize[0]
				
				if position[0] >= destination.width()
					i += @size_[0] - x
					break
				
			position[0] -= tileSize[0] * x
			position[1] += tileSize[1]
			
			break if position[1] >= destination.height()
				
	pxRender: (
		tileset
		destination
	) ->
		
		tiles = tileset.tiles()
		image = tileset.image()
		
		imageWidth = image.width() * 4
		destinationWidth = destination.width() * 4
		tileSize = tileset.tileSize()
		tileSize4 = Vector.scale tileset.tileSize(), 4
		dh = destinationWidth * tileSize[1]
		
		indexMap = []
		
		for y in [0...tiles[1]]
			for x in [0...tiles[0]]
				indexMap.push y * tileSize[1] * imageWidth + x * tileSize[0] * 4
		
		destination.lockPixels()
		image.lockPixels()
		
		i = 0
		gt = 0
		
		y = 0
		while y++ < @size_[1]
			
			x = 0
			while x++ < @size_[0]
				
				t = indexMap[@tileIndices_[i]]
				
				ty = 0
				while ty++ < tileSize[1]
					
					tx = 0
					while tx++ < tileSize[0]
						
						for p in [0...4]
							
							destination.Pixels.data[gt + p] = image.Pixels.data[t + p]
						
						gt += 4
						t += 4
						
					gt -= tileSize4[0]
					t -= tileSize4[0]
					
					gt += destinationWidth
					t += imageWidth
					
				gt -= dh
				gt += tileSize4[0]
				
				i += 1
				
			gt -= destinationWidth
			gt += dh
		
		image.unlockPixels()
		destination.unlockPixels()
			
	render: (
		position
		tileset
		destination
		clip = [0, 0, 0, 0]
		mode = Image.DrawMode_Blend
	) ->
		
		return unless @tileIndices_?
		
		tileSize = tileset.tileSize()
		
		if Vector.isZero Rectangle.size clip
			
			clip[2] = destination.width()
			clip[3] = destination.height()
		
		matrixRenderer clip, tileSize, (matrix) =>
			
			index = @tileIndex matrix.start
			tileset.render(
				Vector.sub(
					Vector.mul matrix.start, tileSize
					position
				)
				destination
				index
				mode
				matrix.clip
			) if index
				
# Helper function - Ease a lot of the initial calculations involved with doing
# partial tile matrix rendering. Returns an object with useful calculated
# results.
matrixBreaker = (clip, unit) ->

	start = Vector.floor Vector.div(
		Rectangle.position clip
		unit
	)
	endOffset = [
		(clip[0] + clip[2]) % unit[0]
		(clip[1] + clip[3]) % unit[1]
	]
	start: start
	endOffset: endOffset
	area: Vector.add(
		[
			if endOffset[0] then 1 else 0
			if endOffset[1] then 1 else 0
		]
		Vector.sub(
			Vector.floor Vector.div(
				Vector.add(
					Rectangle.position clip
					Rectangle.size clip
				)
				unit
			)
			start
		)
	)
	startOffset: [
		clip[0] % unit[0]
		clip[1] % unit[1]
	]
	clip: Rectangle.compose [0, 0], unit
	
# Helper function - Eases rendering of clipped tile matrices.
matrixRenderer = (clip, unit, f) ->

	matrix = matrixBreaker clip, unit
	for y in [0...matrix.area[1]]
		matrix.clip[1] = 0
		matrix.clip[3] = unit[1]
		
		matrix.clip[1] = matrix.startOffset[1] if y is 0
		if y is matrix.area[1] - 1
			matrix.clip[3] = matrix.endOffset[1] if matrix.endOffset[1] > 0
		matrix.clip[3] -= matrix.clip[1]
		
		for x in [0...matrix.area[0]]
			matrix.clip[0] = 0
			matrix.clip[2] = unit[0]
			
			matrix.clip[0] = matrix.startOffset[0] if x is 0
			if x is matrix.area[0] - 1
				matrix.clip[2] = matrix.endOffset[0] if matrix.endOffset[0] > 0
			matrix.clip[2] -= matrix.clip[0]
			
			f matrix
			
			matrix.start[0] += 1
			
		matrix.start[0] -= matrix.area[0]
		matrix.start[1] += 1
		
	undefined

module.exports.DisplayCommand = class extends DisplayCommand
	
	constructor: (
		list
		@layer_
		@tileset_
		rectangle
		
		# We take an approach here as tradeoff between space and time. This
		# approach allocates 16 half-window-sized images which compose a 4x4
		# grid. The visible portion is in the middle of this grid, and when
		# the edge of the grid is approached, the next image is cached.
		@canvasSize_ = Graphics.window.size()
		@cacheChunkScale_ = .5
	) ->
		super list, rectangle
		
		@setCacheChunkSize()
		
	setCacheChunkSize: ->
		
		@cacheChunkSize_ = Vector.round(
			Vector.scale @canvasSize_, @cacheChunkScale_
		)
		
		@cache_ = {}
		@freeQuads_ = []
		
	invalidateCache: (rect) ->
		
		topLeft = Vector.mul(
			Vector.floor Vector.div(
				Rectangle.position rect
				@cacheChunkSize_
			)
			@cacheChunkSize_
		)
		
		topLeftKey = Rectangle.compose(
			topLeft
			@cacheChunkSize_
		).toString()
		
		@cache_[topLeftKey].fill 0, 0, 0, 0
		@freeQuads_.push @cache_[topLeftKey]
		delete @cache_[topLeftKey]
		
	render: (position, clip, destination) ->
		
		chunkSide = 2 + 1 / @cacheChunkScale_
		
		if _.isEmpty @cache_
			for i in [0...chunkSide * chunkSide]
				@cache_[i] = new Image @cacheChunkSize_
		
		section = Vector.mul(
			Vector.floor(
				Vector.div @list().position(), @cacheChunkSize_
			)
			@cacheChunkSize_
		)
		
		cache = {}
		
		offset = Vector.scale @cacheChunkSize_, -1
		for y in [0...chunkSide]
			for x in [0...chunkSide]
				
				rect = Rectangle.compose(
					Vector.add offset, section
					@cacheChunkSize_
				)
				
				offset[0] += @cacheChunkSize_[0]
				
				if @cache_[rect]?
					cache[rect] = @cache_[rect]
		
			offset[0] -= @cacheChunkSize_[0] * chunkSide
			offset[1] += @cacheChunkSize_[1]
			
		for rect, image of @cache_
			unless cache[rect]?
				image.fill 0, 0, 0, 0
				@freeQuads_.push image
				
		@cache_ = cache
		
		offset = Vector.scale @cacheChunkSize_, -1
		for y in [0...chunkSide]
			for x in [0...chunkSide]
				
				rect = Rectangle.compose(
					Vector.add offset, section
					@cacheChunkSize_
				)
				
				offset[0] += @cacheChunkSize_[0]
				
				continue if rect[0] < 0
				continue if rect[1] < 0
				continue if rect[0] >= @size()[0]
				continue if rect[1] >= @size()[1]
				
				unless @cache_[rect]?
					
					@layer_.render(
						Rectangle.position rect
						@tileset_
						@cache_[rect] = @freeQuads_.pop()
						rect
						255
						Image.DrawMode_Replace
					)
					
			offset[0] -= @cacheChunkSize_[0] * chunkSide
			offset[1] += @cacheChunkSize_[1] 
		
		matrixRenderer clip, @cacheChunkSize_, (matrix) =>
			
			rect = Rectangle.compose(
				Vector.mul matrix.start, @cacheChunkSize_
				@cacheChunkSize_
			)
			
			@cache_[rect].render(
				Vector.sub(
					Vector.add(
						Vector.mul matrix.start, @cacheChunkSize_
						matrix.clip
					)
					@list().position()
				)
				destination
				255
				Image.DrawMode_Blend
				matrix.clip
			)
