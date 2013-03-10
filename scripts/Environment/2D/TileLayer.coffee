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
		
		if @tileIndices_?
			
			debased = base64.fromBase64 @tileIndices_.toString()
			compressed = JSON.parse "[#{debased}]"
			
			decompressed = Lzw.decompress compressed
			@tileIndices_ = JSON.parse "[#{decompressed}]"
			
		else
			@tileIndices_ = (0 for i in [0...Vector.area @size_])
		
		defer.resolve()
			
		defer.promise
	
	toJSON: ->
		
		tileIndices = if 0 isnt Math.max.apply Math, @tileIndices_
			compressed = Lzw.compress @tileIndices_.toString()
			base64.toBase64 compressed.toString()
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
		
		offset = Vector.scale(
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
		
				tileset.render(
					offset
					destination
					index
				) if index = @tileIndex start
				
				offset[0] += tileSize[0]
				start[0] += 1
				
			offset[0] -= tileSize[0] * area[0]
			offset[1] += tileSize[1]

			start[0] -= area[0]
			start[1] += 1
