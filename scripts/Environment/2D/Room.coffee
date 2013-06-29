
_ = require 'Utility/underscore'
Debug = require 'Debug'
Entity = require 'Entity/Entity'
Image = require('Graphics').Image
Physics = require 'Physics/Physics'
Q = require 'Utility/Q'
Vector = require 'Extension/Vector'

module.exports = Room = class
	
	@layerCount: 5
		
	constructor: (size = [0, 0]) ->
		
		@tileset_ = new Room.Tileset()
		@layers_ = []
		@size_ = Vector.copy size
		@sizeInPx_ = [0, 0]
		@name_ = ''
		@entities_ = []
		@collision_ = []
		
		@_physics = new Physics()
		@_physics.addFloor()
		@_physics.setWalls @size_
	
		@layers_[i] = new Room.TileLayer size for i in [0...Room.layerCount]

	fromObject: (O) ->
	
		@["#{i}_"] = O[i] for i of O
		
		tilesetPromise =  if O.tilesetUri?
			Room.Tileset.load O.tilesetUri
		else
			@tileset_
		Q.when(tilesetPromise).then (@tileset_) =>
		
		@setSize Vector.copy O.size
		
		@layers_ = []
		layerPromises = for layerO, i in O.layers
			@layers_[i] = new Room.TileLayer()
			@layers_[i].fromObject layerO
			
		@entities_ = []
		entityPromises = for entityO in O.entities ? []
			Entity.load entityO.uri, entityO.traits ? []
		Q.all(entityPromises).then (entities) =>
			@addEntity entity for entity in entities
		
		Q.all(_.flatten [
			entityPromises
			layerPromises
			[tilesetPromise]
		], true).then =>
			
			@setTileset @tileset_
			
			this
		
	physics: -> @_physics
	
	reset: -> entity.reset() for entity in @entities_
		
	height: -> @size_[1]
	width: -> @size_[0]
	
	size: -> @size_
	_calculateSizeInPx: -> @sizeInPx_ = Vector.mul @size_, @tileset_.tileSize()
	sizeInPx: -> @sizeInPx_
	setSize: (size) ->
		return if Vector.equals @size_, size
		
		@size_ = Vector.copy size
		
		@_calculateSizeInPx()
		@setWalls()
		
		layer.setSize size for layer in @layers_
	
	layer: (index) -> @layers_[index]
	layerCount: -> @layers_.length
	
	tileset: -> @tileset_
	setTileset: (@tileset_) ->
		
		layer.setTileset @tileset_ for layer in @layers_
		
		@_calculateSizeInPx()
		@setWalls()		
	
	setWalls: -> @_physics.setWalls @sizeInPx()
	
	# Get a tile index by passing in a position vector.
	tileIndexFromPosition: (position) ->
		@layers_[0].tileIndexFromPosition position
	
	tick: ->
		
		entity.tick() for entity in @entities_
		
		@_physics.tick()
	
	name: -> @name_
	
	entityCount: -> @entities_.length
	
	entity: (index) -> @entities_[index]
	
	addEntity: (entity) ->
		
		entity.setTraitVariables room: this
		
		@entities_.push entity
		
		entity
	
	removeEntity: (entity) ->
		
		return if -1 is index = @entities_.indexOf entity
		
		@entities_.splice index, 1
	
	entityList: (position, distance) ->
		list = []
		for entity in @entities_
			if distance >= Vector.cartesianDistance entity.position(), position
				list.push entity
		list
	
	toImage: (tileset) ->
		
		image = new Image Vector.mul tileset.tileSize(), @size_
		
		layer.render [0, 0], tileset, image for layer in @layers_
			
		image
	
	toJSON: ->
		
		traitArrayToObject = (traits) ->
			object = {}
			object[trait.type] = trait.state ? {} for trait in traits
			object
		
		entities = _.map @entities_, (entity) ->
			if entity.hasTrait 'Inhabitant'
				return unless entity.saveWithRoom()
			
			entity.traitExtensions()
		
		entities = _.filter entities, _.identity
		 
		layers = _.map @layers_, (layer) -> layer.toJSON()
		
		name: @name_
		size: @size_
		layers: layers
		collision: @collision_
		entities: entities
		tilesetUri: @tileset_?.uri()
		
Room.TileLayer = require 'Environment/2D/TileLayer'
Room.Tileset = require 'Environment/2D/Tileset'
		