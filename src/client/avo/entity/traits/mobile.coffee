
Promise = require 'vendor/bluebird'
Vector = require 'avo/extension/vector'

Trait = require './trait'

module.exports = class extends Trait

  stateDefaults: ->

    immovable: false
    isMobile: true
    isMoving: false
    mobilityAnimationIndex: 'moving'
    movingSpeed: 0

  constructor: ->
    super

    @_move = null
    @_movementHandler = null

  properties: ->

    immovable: {}
    isMobile: {}
    isMoving: {}
    mobilityAnimationIndex: {}
    movingSpeed: {}

  actions: ->

    move: (vector) ->

      isZero = Vector.isZero vector

      @entity.setDirection(
        Vector.toDirection vector, @entity.directionCount()
      ) unless isZero

      return unless @entity.isMobile()

      @entity.applyMovement(
        Vector.hypotenuse vector
        @entity.movingSpeed()
      )

      return

    moveTo:

      f: (destination, state) ->

        deferred = Promise.defer()

        hypotenuse = Vector.hypotenuse(
          destination
          @entity.position()
        )

        checkMovementEnd = =>

          overshot = Vector.overshot @entity.position(), hypotenuse, destination
          entityPosition[i] = destination[i] if overshot[i] for i in [0, 1]

          diff = Vector.abs Vector.sub destination, entityPosition
          if diff[0] <= 1 and diff[1] <= 1

            @entity.off 'afterPhysicsTick', checkMovementEnd
            @entity.setPosition destination

            deferred.resolve()

        @entity.on 'afterPhysicsTick', checkMovementEnd

        state.setPromise deferred.promise

        state.setTicker =>

          @entity.move hypotenuse = Vector.hypotenuse(
            destination
            @entity.position()
          )

    pursue:

      f: (entity) -> @entity.move @entity.hypotenuseToEntity entity

    pursueFor:

      f: (entity, ms, track, state) ->
        self = this

        hypotenuse = null
        do doTracking = -> hypotenuse = self.entity.hypotenuseToEntity entity

        state.setPromise (deferred = Promise.defer()).promise

        waited = 0
        state.setTicker (elapsed) ->
          doTracking() if track
          self.entity.move hypotenuse
          deferred.resolve() if (waited += elapsed) >= ms
