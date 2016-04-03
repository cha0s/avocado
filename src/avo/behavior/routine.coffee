
Actions = require './actions'
BehaviorItem = require './behaviorItem'
Invocation = require './invocation'

Promise = require 'avo/vendor/bluebird'

module.exports = class Routine extends BehaviorItem

  constructor: ->

    @_actions = new Actions()

  fromObject: (O) ->

    Promise.allAsap [
      @_actions.fromObject O.actions ? []
    ], => this

  tick: (context, elapsed) ->

    @_actions.tick context, elapsed

  toJSON: ->

    actions: @_actions.toJSON()
