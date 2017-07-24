
FunctionExt = require 'avo/extension/function'
Vector = require 'avo/extension/vector'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

module.exports = class Input

  mixins = [
    EventEmitter
  ]

  constructor: -> mixin.call this for mixin in mixins

  FunctionExt.fastApply Mixin, [@::].concat mixins

  attachListeners: (config) ->
    for type of config
      if config[type]
        require("./#{type}").attachListeners this, config[type]
