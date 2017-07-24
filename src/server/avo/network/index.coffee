
Promise = require 'vendor/bluebird'

EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

ConnectionManager = require './connection-manager'

instance = null

module.exports = class Network

  mixins = [
    EventEmitter
    ConnectionManager
  ]

  constructor: ->
    mixin.call this for mixin in mixins

    self = this

    @on 'avo-raw-connection', (socket) ->

      self.addConnection socket

      socket.on 'disconnect', -> self.removeConnection socket.id

  FunctionExt.fastApply Mixin, [@::].concat mixins

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