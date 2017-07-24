
MathExt = require 'avo/extension/math'
Vector = require 'avo/extension/vector'

Trait = require 'avo/entity/traits/trait'

module.exports = class Physical extends Trait

  @dependencies: ['shaped']

  constructor: ->
    super

    @_body = null
    @_physics = null

  actions: ->

    addToPhysics: (@_physics) -> @_physics.addEntity @entity

    applyForce: (vector, force) -> @_body.applyForce vector, force

    applyMovement: (vector, force) -> @_body.applyMovement vector, force

    applyImpulse: (vector, force) -> @_body.applyImpulse vector, force

    beforePhysicsTick: (elapsed) ->

      @_body.forceMovement elapsed

      v = @_body.velocity()
      @entity.setIsMoving (16 <= Math.abs v[0]) or (16 <= Math.abs v[1])

    afterPhysicsTick: (elapsed) ->

      @_body.unforceMovement elapsed

      @entity.setPosition @_body.position()

      dampener = 1 - (((5 / @entity.dampeningTime()) * elapsed) / 1000)
      @_body.setVelocity Vector.scale @_body.velocity(), Math.max 0, dampener

    removeFromPhysics: ->
      return unless @_physics? and @_body?

      @_physics.removeEntity @entity

      @_body = null
      @_physics = null

    setBody: (@_body) ->

  values: ->

    body: -> @_body

    dampeningTime: -> .4

  signals: ->

    destroyed: -> @entity.removeFromPhysics()

    positionChanged: -> @_body.setPosition @entity.position()
