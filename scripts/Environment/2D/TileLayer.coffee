# **TileLayer** represents a 2D tile matrix. It is a glorified array of
# tile indices which index into a tileset.

_ = require 'Utility/underscore'
Graphics = require 'Graphics'
Packer = require 'Utility/Packer'
Promise = require 'Utility/bluebird'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = TileLayer = class
	
	constructor: (size = [0, 0]) ->
		
		@tileset_ = new TileLayer.Tileset()
		
		# The tile index data.
		area = Vector.area size
		@tileIndices_ = if 0 is area
			null
		else
			0 for i in [0...area]
	
		# The size of the tile matrix.
		@size_ = Vector.copy size
		
	fromObject: (O) ->
		
		@["#{i}_"] = O[i] for i of O
		
		@size_ = Vector.copy @size_
		
		@tileIndices_ = if @tileIndices_?
			Packer.unpack @tileIndices_
		else
			(0 for i in [0...Vector.area @size_])
		
		Promise.resolve this
	
	toJSON: ->
		
		nonZero = do =>
			for tileIndex in @tileIndices_
				return true if tileIndex > 0
			false
		
		tileIndices = if nonZero
			Packer.pack @tileIndices_
		else
			null
			
		tileIndices: tileIndices
		size: Vector.copy @size_
		
	copy: ->
		layer = new TileLayer()
		layer.fromObject @toJSON()
		layer 
	
	size: -> @size_
	height: -> @size_[1]
	width: -> @size_[0]
	
	# Resize the layer, losing as little information as possible.
	setSize: (size) ->
		return if Vector.equals @size_, size
		
		tileIndices = new Array size[0] * size[1]
		for y in [0...size[1]]
			for x in [0...size[0]]
				tileIndices[y * size[0] + x] = @tileIndex x, y
				
		@size_ = size
		@tileIndices_ = tileIndices
		
		this
	
	tileset: -> @tileset_
	setTileset: (@tileset_) ->
	
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
	
	# Get a tile index by passing in a position vector.
	tileIndexFromPosition: (position) ->
		Vector.floor Vector.div position, @tileset_.tileSize()
	
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
	
	renderTile: (destination, tilePosition, renderPosition) ->
	
		@tileset_.render(
			renderPosition
			destination
			index
		) if index = @tileIndex tilePosition
		
	render: (
		position
		destination
		clip = [0, 0, 0, 0]
		mode = Graphics.GraphicsService.BlendMode_Blend
	) ->
		
		return unless @tileIndices_?
		
		tileSize = @tileset_.tileSize()
		
		if Vector.isZero Rectangle.size clip
			
			clip[2] = destination.width()
			clip[3] = destination.height()
		
		offset = Vector.add position, Vector.scale(
			Vector.mod clip, tileSize
			-1
		)
		
		start = Vector.floor Vector.div clip, tileSize
		
		area = Vector.floor Vector.div(
			Rectangle.size clip
			tileSize
		)
		
		for i in [0..1]
			area[i] += 2
		
		for y in [0...area[1]]
			
			for x in [0...area[0]]
				
				@renderTile destination, start, offset
				
				offset[0] += tileSize[0]
				start[0] += 1
				
			offset[0] -= tileSize[0] * area[0]
			offset[1] += tileSize[1]

			start[0] -= area[0]
			start[1] += 1

TileLayer.Tileset = require 'Environment/2D/Tileset'
