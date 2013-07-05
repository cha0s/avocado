
_ = require 'Utility/underscore'
Debug = require 'Debug'
Entity = require 'Entity/Entity'
EventEmitter = require 'Mixin/EventEmitter'
Image = require('Graphics').Image
Mixin = require 'Mixin/Mixin'
Physics = require 'Physics/Physics'
PrivateScope = require 'Utility/PrivateScope'
Property = require 'Mixin/Property'
Q = require 'Utility/Q'
Vector = require 'Extension/Vector'
VectorMixin = require 'Mixin/Vector'

module.exports = Room = class
	
	@defaultLayerCount: 5
	
	mixins = [
		EventEmitter
		Property 'name', ''
		Property 'physics', new Physics()
		SizeProperty = VectorMixin 'size', 'width', 'height'
		TilesetProperty = Property 'tileset', null
	]
	
	constructor: ->
		
		mixin.call this for mixin in mixins
		PrivateScope.call @, Private, 'roomScope'
		
		@physics().addFloor()
		
	Mixin.apply null, [@::].concat mixins
	
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'roomScope'
	)
	
	forwardCallToPrivate 'addEntity'
		
	forwardCallToPrivate 'entity'
		
	forwardCallToPrivate 'entityCount'
		
	forwardCallToPrivate 'entityList'
		
	forwardCallToPrivate 'fromObject'
		
	forwardCallToPrivate 'layer'
		
	forwardCallToPrivate 'layerCount'
		
	forwardCallToPrivate 'removeEntity'
		
	forwardCallToPrivate 'setSize'
		
	forwardCallToPrivate 'setTileset'
		
	forwardCallToPrivate 'sizeInPx'
		
	forwardCallToPrivate 'tick'
		
	forwardCallToPrivate 'tileIndexFromPosition'
		
	forwardCallToPrivate 'toImage'
		
	forwardCallToPrivate 'toJSON'
		
	Private = class
		
		constructor: (_public) ->
			
			@collision = []
			@entities = []
			@layers = for i in [0...Room.defaultLayerCount]
				new Room.TileLayer()
			
			@_sizeInPx = [0, 0]
			
			_public.on 'sizeChanged', => @recomputeTotalSize()
			_public.on 'tilesetChanged', => @recomputeTotalSize()
			
		addEntity: (entity) ->
			
			_public = @public()
			
			return if _.contains @entities, entity
			
			entity.setTraitVariables room: _public
			@entities.push entity
			entity
		
		entity: (index) -> @entities[index]
		
		entityCount: -> @entities.length
		
		entityList: (position, distance) ->
			list = []
			for entity in @entities
				if distance >= Vector.cartesianDistance entity.position(), position
					list.push(
						distance: distance
						entity: entity
					)
			list.sort (l, r) -> l.distance - r.distance
			_.map list, (spec) -> spec.entity
		
		fromObject: (O) ->
			
			_public = @public()
			
			entityPromises = if (O.entities ?= []).length > 0
				
				promises = for entityO in O.entities
					Entity.load entityO.uri, entityO.traits ? []
				
				Q.all(promises).then (entities) =>
					@entities = []
					_public.addEntity entity for entity in entities
				
				promises
			else
				[]
			
			layerPromises = if (O.layers ?= []).length > 0
				
				promises = for layerO in O.layers
					(new Room.TileLayer()).fromObject layerO
				
				Q.all(promises).then (layers) => @layers = layers
				
				promises
			else
				[]
			
			_public.setName O.name
			
			tilesetPromise = if O.tilesetUri?
				Room.Tileset.load O.tilesetUri
			else
				O.tileset
			Q.when(tilesetPromise).then (tileset) =>
				_public.setTileset tileset
			
			promises = [
				tilesetPromise
			].concat(
				entityPromises
				layerPromises
			)		
			
			Q.all(promises).then =>
				
				_public.setSize O.size
				
				_public
	
		layer: (index) -> @layers[index]
		
		layerCount: -> @layers.length
	
		recomputeTotalSize: ->
			
			_public = @public()
			
			@_sizeInPx = Vector.mul(
				_public.size()
				_public.tileset()?.tileSize() ? [0, 0]
			)
			
			_public.physics().setWalls @_sizeInPx
			
		removeEntity: (entity) ->
			return if -1 is index = @entities.indexOf entity
			
			@entities.splice index, 1
		
		setSize: (size) ->
		
			_public = @public()
			
			SizeProperty::setSize.call _public, size
			
			layer.setSize size for layer in @layers
	
		setTileset: (tileset) ->
		
			_public = @public()
			
			TilesetProperty::setTileset.call _public, tileset
			
			layer.setTileset tileset for layer in @layers
	
		sizeInPx: -> @_sizeInPx
			
		tick: ->
			
			_public = @public()
			
			for entity in @entities
				entity.tick()
			
			for entity in @entities
				_public.removeEntity entity if entity.isDestroyed()
			
			_public.physics().tick()
	
		tileIndexFromPosition: (position, layerIndex = 0) ->
			
			@layers[layerIndex].tileIndexFromPosition position
	
		toImage: (tileset) ->
		
			_public = @public()
			
			image = new Image _public.sizeInPx()
			layer.render [0, 0], image for layer in @layers
			image
		
		toJSON: ->
			
			_public = @public()
			
			entities = for entity in @entities
				if entity.hasTrait 'Inhabitant'
					continue unless entity.saveWithRoom()
				
				extensions = entity.traitExtensions()
				
				uri: entity.uri()
				traits: extensions.traits
			
			name: _public.name()
			size: _public.size()
			layers: _.map @layers, (layer) -> layer.toJSON()
			collision: @collision
			entities: entities
			tilesetUri: _public.tileset()?.uri()
	
Room.TileLayer = require 'Environment/2D/TileLayer'
Room.Tileset = require 'Environment/2D/Tileset'
		