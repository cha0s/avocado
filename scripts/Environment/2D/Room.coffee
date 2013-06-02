
_ = require 'Utility/underscore'
Debug = require 'Debug'
Entity = require 'Entity/Entity'
Image = require('Graphics').Image
Q = require 'Utility/Q'
TileLayer = require 'Environment/2D/TileLayer'
Tileset = require 'Environment/2D/Tileset'
Vector = require 'Extension/Vector'

module.exports = Room = class
	
	@layerCount: 5
		
	constructor: (size = [0, 0]) ->
	
		@tileset_ = new Tileset()
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
		entityPromises = for entityO in O.entities ? []
			Entity.load entityO.uri, entityO.traits ? []
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
	
	reset: -> entity.reset() for entity in @entities_
		
	resize: (w, h) ->
		
		@size_ = if w instanceof Array then Vector.copy(w) else [w, h]
		
		for layer in @layers_
			layer.resize w, h
	
	height: -> @size_[1]
	width: -> @size_[0]
	
	size: -> @size_
	
	layer: (index) -> @layers_[index]
	layerCount: -> @layers_.length
	
	tileset: -> @tileset_
	setTileset: (@tileset_) ->
		
		layer.setTileset @tileset_ for layer in @layers_

	# Get a tile index by passing in a position vector.
	tileIndexFromPosition: (position) ->
		@layers_[0].tileIndexFromPosition position
	
	tick: -> entity.tick() for entity in @entities_
	
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
			
			entityO = entity.toJSON()
			
			originalTraits = traitArrayToObject entity.originalTraits
			currentTraits = traitArrayToObject entityO.traits
			
			entityO.traits = []
			
			sgfy = JSON.stringify
			
			for type, currentState of currentTraits
			
				unless originalTraits[type]?
					entityO.traits.push
						type: type
						state: currentState
					
					continue
					
				state = {}
				stateDefaults = originalTraits[type]
				
				for k, v of _.defaults currentState, JSON.parse sgfy stateDefaults
					state[k] = v if sgfy(v) isnt sgfy(stateDefaults[k])
					
				O = {}
				O.type = type
				
				if _.isEmpty state
					continue if originalTraits[type]?
				else
					O.state = state
				
				entityO.traits.push O
			
			entityO
		
		entities = _.filter entities, _.identity
		 
		layers = _.map @layers_, (layer) -> layer.toJSON()
		
		name: @name_
		size: @size_
		layers: layers
		collision: @collision_
		entities: entities
