
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

module.exports = class Socket

  mixins = [
    EventEmitter
  ]

  constructor: -> mixin.call this for mixin in mixins

  send: (message) ->

  FunctionExt.fastApply Mixin, [@::].concat mixins

