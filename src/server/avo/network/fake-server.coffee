
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

FakeServer = Mixin.toClass [

  EventEmitter

], class FakeServer

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

module.exports = new FakeServer()
