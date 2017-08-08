
Promise = require 'vendor/bluebird'

fs = require 'avo/fs'

EventEmitter = require 'avo/mixin/eventEmitter'
Property = require 'avo/mixin/property'
Mixin = require 'avo/mixin'

Room = require './room'

module.exports = class Environment

  Mixin.toClass this, mixins = [
    EventEmitter

    Property 'description', default: ''
    Property 'label', default: 'New environment'
    Property 'uri', default: null
  ]

  @load: (uri) -> fs.readJsonResource(uri).then (O) ->
    O.uri = uri
    (new Environment()).fromObject O

  constructor: ->
    mixin.call this for mixin in mixins

    @_rooms = []

  fromObject: (O) ->

    @setLabel O.label if O.label?
    @setDescription O.description if O.description?
    @setUri O.uri if O.uri?

    @_rooms = []

    roomPromises = for roomO in O.rooms
      (new Room()).fromObject(roomO).then @addRoom.bind this

    Promise.all(roomPromises).then ((self) -> -> self) this

  addRoom: (room) ->

    @_rooms.push room
    @emit 'roomAdded', room

  removeRoom: (room) ->
    return if -1 is index = @_rooms.indexOf room

    @_rooms.splice index, 1
    @emit 'roomRemoved', room

  room: (index) -> @_rooms[index]

  roomCount: -> @_rooms.length

  rooms: -> @_rooms

  toJSON: ->

    description: @description()
    label: @label()
    rooms: @_rooms
