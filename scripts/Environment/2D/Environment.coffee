
_ = require '../../Utility/underscore'
{CoreService} = require 'Core'
Debug = require '../../Debug'
Promise = require '../../Utility/bluebird'

module.exports = Environment = class
	
	@load: (uri) ->
	
		CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			environment = new Environment()
			environment.fromObject O
		
	constructor: ->
		
		@rooms_ = []
		@name_ = ''
		@description_ = ''
		
	fromObject: (O) ->
		
		@["#{i}_"] = O[i] for i of O
		
		@rooms_ = []
		roomPromises = for roomO in O.rooms
			room = new Environment.Room()
			@addRoom room
			room.fromObject roomO
			
		Promise.all(roomPromises).then => this
			
	addRoom: (room) -> @rooms_.push room
	room: (index) -> @rooms_[index]
	roomCount: -> @rooms_.length
	
	name: -> if @name_ is '' then @uri_ else @name_
	setName: (@name_) ->
	
	description: -> @description_
	setDescription: (@description_) ->
	
	uri: -> @uri_
	setUri: (@uri_) ->
	
	toJSON: ->
		
		name: @name_
		rooms: @rooms_

Environment.Room = require './Room'
