
Vector = require 'avo/extension/vector'

Ticker = require 'avo/timing/ticker'
timing = require 'avo/timing'

Promise = require 'vendor/bluebird'

Trait = require 'avo/entity/traits/trait'

module.exports = class Projectile extends Trait

  @dependencies: [
    'child'
    'corporeal'
    'visible'
  ]

  stateDefaults: ->

    count: 1
    orientation: 'toward'

    projectileEntity: ''

  actions: ->

    attack: (state) ->

      tickerDeferred = Promise.defer()

      ticker = new Ticker @state.swingSpeed
      ticker.on 'tick', -> tickerDeferred.resolve()

      @entity.setIsCheckingCollisions true
      @entity.setIsVisible true

      elapsedTime = 0

      do tick = (elapsed) =>
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
