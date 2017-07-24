
Promise = require 'vendor/bluebird'

FunctionExt = require 'avo/extension/function'

Transition = require 'avo/mixin/transition'
Lfo = require 'avo/mixin/lfo'

behaviorContext = require 'avo/behavior/context'
Timing = require 'avo/timing'

Trait = require './trait'

module.exports = Existent = class extends Trait

  constructor: (entity) ->
    super

    @_variables = {}

    @_context = behaviorContext.defaultContext()
    @_context.entity = entity

  stateDefaults: ->

    name: 'Untitled'

  properties: ->

    name: {}

  actions: ->

    destroy: ->
      @entity.setIsTicking false
      @entity.emit 'destroyed'

    setVariable: (key, value) ->

      @_variables[key] = value

    lfo: (properties, duration, state) ->

      lfo = FunctionExt.fastApply Lfo::lfo, arguments, @entity

      state.setPromise lfo.promise
      state.setTicker (elapsed) -> lfo.tick elapsed

    transition: (properties, duration, easing, state) ->

      unless state?
        state = easing
        easing = null

      transition = FunctionExt.fastApply(
        Transition::transition
        [properties, duration, easing]
        @entity
      )

      state.setPromise transition.promise
      state.setTicker (elapsed) -> transition.tick elapsed

    signal: -> FunctionExt.fastApply @entity.emit, arguments, @entity

  values: ->

    context: -> @_context

    variable: (key) -> @_variables[key]
