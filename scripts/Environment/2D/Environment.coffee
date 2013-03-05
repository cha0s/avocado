CoreService = require('Core').CoreService
Room = require 'Environment/2D/Room'
Tileset = require 'Environment/2D/Tileset'
upon = require 'Utility/upon'

module.exports = Environment = class
	
	constructor: ->
		
		@tileset_ = new Tileset()
		@rooms_ = []
		@name_ = ''
		@description_ = ''
		
	fromObject: (O) ->
		
		defer = upon.defer()
	
		@["#{i}_"] = O[i] for i of O
		
		if O.tilesetUri?
			tilesetPromise = Tileset.load(O.tilesetUri).then (@tileset_) =>
			
		promiseRoom = (O, i) =>
			room = new Room()
			room.fromObject(O).then (room) => @rooms_[i] = room
		
		roomPromises = for roomInfo, i in O.rooms
			promiseRoom roomInfo, i
			
		upon.all([
			tilesetPromise
		].concat(
			roomPromises
		)).then ->
			defer.resolve()
			
		defer.promise
	
	@load: (uri) ->
	
		defer = upon.defer()
		
		CoreService.readJsonResource(uri).then (O) ->
		
			environment = new Environment()
			
			O.uri = uri
			environment.fromObject(O).then ->
				defer.resolve environment
		
		defer.promise
	
	room: (index) -> @rooms_[index]
	roomCount: -> @rooms_.length
	
	tileset: -> @tileset_
	setTileset: (@tileset_) ->
	
	name: -> if @name_ is '' then @uri_ else @name_
	setName: (@name_) ->
	
	description: -> @description_
	setDescription: (@description_) ->
	
	uri: -> @uri_
	setUri: (@uri_) ->
	
	copy: ->
		
		environment = new Environment()
		environment.fromObject @toJSON()
		
		environment
	
	toJSON: ->
		
		name: @name_
		tilesetUri: @tileset_?.image()?.uri()
		rooms: @rooms_