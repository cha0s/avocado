
Promise = require 'avo/vendor/bluebird'

EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

Collection = require './collection'
Invocation = require './invocation'

module.exports = class Invocations extends Collection 'invocations'

  parallel: (context, state) ->

    states = for invocation in @_invocations
      invocation.invoke context, _state = new Invocation.State()
      _state

    # Any actual action promises?
    if states.reduce ((l, r) -> r.promise()? or l), false
      state.setTicker (elapsed) -> _state.tick elapsed for _state in states
      state.setPromise Promise.all states.map (e) -> e.promise()
