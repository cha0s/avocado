
_ = require 'Utility/underscore'
Debug = require 'Debug'
Entity = require 'Entity/Entity'
Image = require('Graphics').Image
Q = require 'Utility/Q'
TileLayer = require 'Environment/2D/TileLayer'
Vector = require 'Extension/Vector'

module.exports = Room = class
	
	@layerCount: 5
		
	constructor: (size = [0, 0]) ->
	
		@layers_ = []
		@size_ = Vector.copy size
		@name_ = ''
		@entities_ = []
		@collision_ = []
		
		@layers_[i] = new TileLayer size for i in [0...Room.layerCount]

	fromObject: (O) ->
	
		@["#{i}_"] = O[i] for i of O
		
		@size_ = Vector.copy O.size
		
		@layers_ = []
		layerPromises = for layerO, i in O.layers
			@layers_[i] = new TileLayer()
			@layers_[i].fromObject layerO
			
		@entities_ = []
		entityPromises =
			((entityO) ->
				Entity.load(entityO.uri).then (entity) ->
					entity.extendTraits entityO.traits ? []
			) entityO for entityO in O.entities ? []
		Q.all(entityPromises).then (entities) =>
			@addEntity entity for entity in entities
		
		Q.all(_.flatten [
			entityPromises
			layerPromises
		], true).then => this
		
	copy: ->
		room = new Room()
		room.fromObject @toJSON()
		room
	
	reset: (variables = {}) ->
		variables.room = this
		entity.reset variables for entity in @entities_
		
	resize: (w, h) ->
		
		@size_ = if w instanceof Array then Vector.copy(w) else [w, h]
		
		for layer in @layers_
			layer.resize w, h
	
	height: -> @size_[1]
	width: -> @size_[0]
	
	size: -> @size_
	
	layer: (index) -> @layers_[index]
	layerCount: -> @layers_.length
	
	tick: -> entity.tick() for entity in @entities_
	
	name: -> @name_
	
	entityCount: -> @entities_.length
	
	addEntity: (entity) ->
		
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
		
		entities = _.map @entities_, (entity) ->
			
			uri: entity.uri
			traits: entity.traitExtensions()
		
		layers = _.map @layers_, (layer) -> layer.toJSON()
		
		name: @name_
		size: @size_
		layers: layers
		collision: @collision_
		entities: entities
