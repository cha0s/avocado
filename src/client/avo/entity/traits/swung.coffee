
Vector = require 'avo/extension/vector'

Ticker = require 'avo/timing/ticker'
timing = require 'avo/timing'

Promise = require 'vendor/bluebird'

Trait = require 'avo/entity/traits/trait'

module.exports = class Sword extends Trait

  @dependencies: [
    'child'
    'corporeal'
    'visible'
  ]

  stateDefaults: ->

    directionModifiers:
      0: position: [-20, -20], rotation: [1.75 * Math.PI, 2.25 * Math.PI]
      1: position: [15, -25], rotation: [.25 * Math.PI, .75 * Math.PI]
      2: position: [20, -20], rotation: [.75 * Math.PI, 1.25 * Math.PI]
      3: position: [10, -15], rotation: [1.25 * Math.PI, 1.75 * Math.PI]

    swingSpeed: 150

  hooks: ->

    attachedOffset: ->

      @state.directionModifiers[@entity.parent().direction()].position

  actions: ->

    attack: (state) ->

      tickerDeferred = Promise.defer()

      ticker = new Ticker @state.swingSpeed
      ticker.on 'tick', -> tickerDeferred.resolve()

      @entity.setIsCheckingCollisions true
      @entity.setIsVisible true

      elapsedTime = 0

      do tick = (elapsed = 0) =>
        direction = @entity.parent().direction()
        @entity.setIsAbove direction is 2 or direction is 3

        directional = @state.directionModifiers[@entity.parent().direction()]
        delta = directional.rotation[1] - directional.rotation[0]
        magnitude = elapsedTime / @state.swingSpeed
        elapsedTime += elapsed
        @entity.setRotation directional.rotation[0] + delta * magnitude

      state.setTicker (elapsed) =>
        tick elapsed if elapsedTime < @state.swingSpeed
        ticker.tick elapsed

      state.setPromise tickerDeferred.promise.then =>

        @entity.setIsCheckingCollisions false
        @entity.setIsVisible false
