
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

module.exports = Mixin.toClass [

  EventEmitter

], class Socket

  send: (message) ->
