
Trait = require 'avo/entity/traits/trait'

module.exports = class Collider extends Trait

  @dependencies: [
    'corporeal'
    'shaped'
  ]

  stateDefaults: ->

    isCheckingCollisions: false
    collisionGroup: 'default'
    collidesWithGroups: ['default']

  properties: ->

    isCheckingCollisions: {}
    collisionGroup: {}

  values: ->

    collidesWith: (entity) ->

      -1 isnt @state.collidesWithGroups.indexOf entity.collisionGroup()

    collidesWithGroups: -> @state.collidesWithGroups

  handler: ->

    ticker: (elapsed) -> @entity.emit 'checkCollision'
