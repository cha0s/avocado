
Vector = require 'avo/extension/vector'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

module.exports = Mixin.toClass [

  EventEmitter

], class Input

  attachListeners: (config) ->
    for type of config
      if config[type]
        require("./#{type}").attachListeners this, config[type]
