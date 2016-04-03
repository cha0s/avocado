
Promise = require 'avo/vendor/bluebird'
Vector = require 'avo/extension/vector'

Trait = require './trait'

module.exports = class extends Trait

  stateDefaults: ->

    isMobile: true
    isMoving: false
    mobilityAnimationIndex: 'moving'
    movingSpeed: 0

  constructor: ->
    super

    @_move = null
    @_movementHandler = null

  properties: ->

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

      @entity.setIsMoving @entity.isMobile() and not isZero

      return unless @entity.isMobile()

      @entity.applyForce vector, @entity.movingSpeed()

      return

      # if @_movementHandler?

      #   @_movementHandler vector, @entity

      # else

      #   @entity.setPosition Vector.add(
      #     @entity.position()
      #     Vector.scale vector, timing.tickElapsed() * force
      #   )


      # if @entity.physicsApplyMovement?

      #   @entity.physicsApplyMovement vector, @entity.movingSpeed()

      # else

      #   @entity.applyImpulse vector, @entity.movingSpeed()

    moveTo:

      f: (destination, state) ->

        deferred = Promise.defer()

        hypotenuse = Vector.hypotenuse(
          destination
          @entity.position()
        )

        checkMovementEnd = =>

          entityPosition = @entity.position()
          for i in [0, 1] when hypotenuse[i] isnt 0

            if hypotenuse[i] < 0
              if entityPosition[i] < destination[i]
                entityPosition[i] = destination[i]

            if hypotenuse[i] > 0
              if entityPosition[i] > destination[i]
                entityPosition[i] = destination[i]

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
