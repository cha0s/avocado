
Promise = require 'vendor/bluebird'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

ConnectionManager = require './connection-manager'

instance = null

module.exports = Mixin.toClass [

  EventEmitter

  ConnectionManager

], class Network

  constructor: ->

    self = this

    @on 'avo-raw-connection', (socket) ->

      self.addConnection socket

      socket.on 'disconnect', -> self.removeConnection socket.id

  listen: (options) ->

  @createInstance: (options) ->
    return instance if instance?

    switch options.type

      when 'local'

        Class = require 'server/avo/network/local'

      when 'socket.io'

        Class = require 'server/avo/network/socket-io'

      when 'tcp'

        Class = require 'server/avo/network/tcp'

    instance = new Class()

    instance.listen options

    return instance

  @getInstance: -> instance