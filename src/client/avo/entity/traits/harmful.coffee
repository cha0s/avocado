
Trait = require 'avo/entity/traits/trait'

module.exports = class Harmful extends Trait

  @dependencies: [
    'corporeal'
  ]

  stateDefaults: ->

    damage: 0
    isHarming: true
    knockback: 512

  properties: ->

    damage: {}
    isHarming: {}
    knockback: {}

  actions: ->

    harm: (entity) ->

      return unless entity.is 'vulnerable'
      return unless @state.isHarming

      entity.receiveHarmFrom @entity

  signals: ->

    dying: -> @entity.setIsHarming false

    intersected: (entity) ->
      return unless entity?

      @entity.harm entity
