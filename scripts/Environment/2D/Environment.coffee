
_ = require 'Utility/underscore'
CoreService = require('Core').CoreService
Debug = require 'Debug'
Q = require 'Utility/Q'
Room = require 'Environment/2D/Room'
Tileset = require 'Environment/2D/Tileset'

module.exports = Environment = class
	
	@load: (uri) ->
	
		CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			environment = new Environment()
			environment.fromObject O
		
	constructor: ->
		
		@tileset_ = new Tileset()
		@rooms_ = []
		@name_ = ''
		@description_ = ''
		
	fromObject: (O) ->
		
		@["#{i}_"] = O[i] for i of O
		
		tilesetPromise =  if O.tilesetUri?
			Tileset.load O.tilesetUri
		else
			@tileset_
		Q.when(tilesetPromise).then (@tileset_) =>	
		
		@rooms_ = []
		roomPromises = for roomO in O.rooms
			room = new Room()
			room.fromObject roomO
			@addRoom room
			
		Q.all(_.flatten [
			[tilesetPromise]
			roomPromises
		], true).then => this
			
	addRoom: (room) -> @rooms_.push room
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
