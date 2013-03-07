
_ = require 'Utility/underscore'
Entity = require 'Entity/Entity'
Image = require('Graphics').Image
TileLayer = require 'Environment/2D/TileLayer'
upon = require 'Utility/upon'
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
	
		defer = upon.defer()
	
		@["#{i}_"] = O[i] for i of O
		
		layerPromises = for layer, i in O.layers
			
			@layers_[i] = new TileLayer()
			@layers_[i].fromObject layer
		
		@size_ = Vector.copy O.size
		
		entityPromises = []
		
		@entities_ = []
		
		if O.entities?
			
			entityPromises = for entityO, i in O.entities
				
				((entityO, i) =>
					
					entityDefer = upon.defer()
					
					Entity.load(entityO.uri).then (entity) =>
					
						extensionDefer = upon.defer()
						
						if entityO.traits?
							entity.extendTraits(entityO.traits).then ->
								extensionDefer.resolve()
						else
							extensionDefer.resolve()
							
						extensionDefer.then(
							=>
								@addEntity entity
								entityDefer.resolve()
							(error) -> defer.reject error
						)
							
					entityDefer.promise
					
				) entityO, i
			
		upon.all(entityPromises.concat(layerPromises)).then(
			=> defer.resolve this
			(error) -> defer.reject new Error "Couldn't instantiate Room: #{error.message}"
		)
		
		defer.promise
		
	copy: ->
		
		room = new Room()
		room.fromObject @toJSON()
		
		room
	
	reset: ->
		
		entity.reset() for entity in @entities_
		
		@startParallax()
		
	startParallax: ->
		
		layer.startParallax() for layer in @layers_
		
	stopParallax: ->
		
		layer.stopParallax() for layer in @layers_
	
	resize: (w, h) ->
		
		@size_ = if w instanceof Array then Vector.copy(w) else [w, h]
		
		for layer in @layers_
			layer.resize w, h
	
	height: -> @size_[1]
	width: -> @size_[0]
	
	size: -> @size_
	
	layer: (index) -> @layers_[index]
	layerCount: -> @layers_.length
	
	tick: ->
	
		entity.tick() for entity in @entities_
	
	name: -> @name_
	
	addEntity: (entity) ->
		
		@entities_.push entity
		
		entity.setRoom this
		
		entity
	
	removeEntity: (entity) ->
		
		return if -1 is index = @entities_.indexOf entity
		
		@entities_.splice index, 1
	
	entityList: (location, distance) ->
		
		for entity in @entities_
			if entity.location().cartesianDistance(location) < distance
				entity
	
	toImage: (tileset) ->
		
		image = new Image Vector.mul tileset.tileSize(), @size_
		
		layer.render [0, 0], tileset, image for layer in @layers_
			
		image
	
	toJSON: ->
		
		entities = _.map @entities_, (entity) ->
			
			uri: entity.uri
			traits: entity.traitExtensions()
		
		name: @name_
		size: @size_
		layers: @layers_
		collision: @collision_
		entities: entities
