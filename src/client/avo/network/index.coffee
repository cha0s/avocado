
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

instance = null

module.exports = class Network

  mixins = [
    EventEmitter
  ]

  constructor: -> mixin.call this for mixin in mixins

  FunctionExt.fastApply Mixin, [@::].concat mixins

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