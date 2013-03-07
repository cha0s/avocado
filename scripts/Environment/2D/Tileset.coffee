
CoreService = require('Core').CoreService
Debug = require 'Debug'
Image = require('Graphics').Image
Rectangle = require 'Extension/Rectangle'
upon = require 'Utility/upon'
Vector = require 'Extension/Vector'

module.exports = Tileset = class

	constructor: ->
	
		@image_ = null
		@tileSize_ = [0, 0]
		@tiles_ = [0, 0]
		@name_ = ''
		@description_ = ''
	
	fromObject: (O) ->
		
		defer = upon.defer()
		
		@["#{i}_"] = O[i] for i of O
		
		if O.image?
			
			imagePromise = null
		
		else
			uri = O.imageUri ? O.uri.replace '.tileset.json', '.png'
			imagePromise = Image.load(uri).then(
				(@image_) =>
			)
		
		upon.all([
			imagePromise
		]).then(
			=>
				@setTileSize @tileSize_
				defer.resolve()
				
			(error) -> defer.reject error
		)
		
		defer.promise
			
	@load: (uri) ->
		
		defer = upon.defer()
		
		CoreService.readJsonResource(uri).then(
			(O) =>
				
				tileset = new Tileset()
				
				O.uri = uri
				tileset.fromObject(O).then(
					-> defer.resolve tileset
					(error) -> defer.reject new Error "Couldn't instantiate Tileset: #{Debug.errorMessage error}"
				)
					
			(error) -> defer.reject new Error "Couldn't instantiate Tileset: #{Debug.errorMessage error}"
		)
		
		defer.promise
	
	toJSON: ->
		
		tileSize: Vector.copy @tileSize_
		name: @name_
		description: @description_
	
	copy: ->
		
		tileset = new Tileset()
		tileset.fromObject @toJSON()
		
		layer
		 
		tileset = new Tileset()
		
		tileset.tileSize_ = Vector.copy @tileSize_
		tileset.tiles_ = Vector.copy @tiles_
		
		tileset.image_ = @image_
		
		tileset
	
	description: -> @description_
	setDescription: (@description_) ->
	
	name: -> if @name_ is '' then @uri_ else @name_
	setName: (@name_) ->
	
	tileSize: -> @tileSize_
	
	tileWidth: -> @tileSize_[0]
	tileHeight: -> @tileSize_[1]
	
	setImage: (image) ->
		
		@image_ = image
		
		@setTileSize @tileSize_
	
	setTileSize: (w, h) ->
		
		@tileSize_ = if h? then [w, h] else w
		
		return unless @image_?

		@tiles_ = Vector.div @image_.size(), @tileSize_
	
	setTileWidth: (width) -> @setTileSize width, @tileHeight()
	setTileHeight: (height) -> @setTileSize @tileWidth(), height
	
	tiles: -> @tiles_
	
	render: (
		location
		destination
		index
		mode
		tileClip = Rectangle.compose [0, 0], @tileSize_
	) ->
		
		return unless @image_?
		
		tileBox = @tileBox index
		tileBox = Rectangle.intersection(
			tileBox
			Rectangle.translated tileClip, Rectangle.position tileBox 
		)
		
		@image_.render(
			Vector.add location, Rectangle.position tileClip
			destination
			255
			mode
			tileBox
		)
	
	image: -> @image_
	
	isValid: ->
		
		return false unless @image_?
		
		not Vector.isNull @image_.size()
	
	tileBox: (index) ->
		
		Rectangle.compose(
			Vector.mul(
				[index % @tiles_[0], Math.floor index / @tiles_[0]]
				@tileSize_
			)
			@tileSize_
		)
		
	tileCount: -> @tiles[0] * @tiles[1]
