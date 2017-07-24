config = require 'avo/config'

Vector = require 'avo/extension/vector'

Trait = require 'avo/entity/traits/trait'

module.exports = class Vulnerable extends Trait

  @dependencies: [
    'corporeal'
  ]

  stateDefaults: ->

    isVulnerable: true
    takesHarmFromCollisionGroups: ['default']

  constructor: ->
    super

    @_damageLocks = []

  properties: ->

    isVulnerable: {}
    takesHarmFromIntersectionGroups: {}

  actions: ->

    receiveHarmFrom: (entity) ->
      return unless @state.isVulnerable

      return if -1 is @state.takesHarmFromCollisionGroups.indexOf(
        entity.collisionGroup()
      )

      # Allow traits to override taking harm.
      for takesHarm in @entity.invoke 'takesHarmFrom', entity
        return unless takesHarm

      for damageLock in @_damageLocks
        return if entity is damageLock.entity

      variance = 1/8
      damage = entity.damage()
      damage -= damage * variance/2
      damage += damage * Math.random() * variance
      damage = Math.round damage

      @entity.emit 'tookDamage', damage

      # Knock back
      knockbackSource = entity
      while knockbackSource.is('child') and (parent = knockbackSource.parent())?
        knockbackSource = parent

      hypotenuse = knockbackSource.hypotenuseToEntity @entity

      @entity.applyImpulse hypotenuse, entity.knockback()

      @entity.setDirection(
        Vector.toDirection(
          Vector.scale hypotenuse, -1
          @entity.directionCount()
        )
      )

      @_damageLocks.push entity: entity, lockTime: 500

  handler: ->

    ticker: (elapsed) ->
      return if @_damageLocks.length is 0

      i = 0
      while i < @_damageLocks.length

        if 0 >= @_damageLocks[i].lockTime -= elapsed
          @_damageLocks.splice i, 1
        else
          i += 1

  signals: ->

    dying: ->

      @entity.setIsVulnerable false
