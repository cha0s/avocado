
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

instance = null

module.exports = Mixin.toClass [

  EventEmitter

], class Network

  connect: (type, options) ->

  send: (message) ->

  @createInstance: (options) ->
    return instance if instance?

    switch options.type

      when 'local'

        Class = require 'avo/network/local'

      when 'socket.io'

        Class = require 'avo/network/socket-io'

      when 'tcp'

        Class = require 'avo/network/tcp'

    instance = new Class()

    instance.connect options

    return instance

  @getInstance: -> instance