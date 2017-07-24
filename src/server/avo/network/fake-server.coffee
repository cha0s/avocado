
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

module.exports = new class FakeServer

  mixins = [
    EventEmitter
  ]

  constructor: -> mixin.call this for mixin in mixins

  FunctionExt.fastApply Mixin, [@::].concat mixins

  clientWrite: (message) ->
    self = this
    setTimeout ->
      self.emit 'clientMessage', message
    , 100

  serverWrite: (message) ->
    self = this
    setTimeout ->
      self.emit 'serverMessage', message
    , 100
