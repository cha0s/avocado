
Promise = require 'vendor/bluebird'

debug = require 'avo/debug'

color = require 'avo/graphics/color'
Primitives = require 'avo/graphics/primitives'

Trait = require 'avo/entity/traits/trait'

module.exports = class Shadowed extends Trait

  @dependencies: [
    'shaped'
  ]

  stateDefaults: ->

    hasShadow: true

  constructor: ->
    super

    @_shadowPrimitives = new Primitives()

  properties: ->

    hasShadow: {}

  signals: ->

    aabbChanged: ->

      aabb = @entity.shapeList().aabb()

      @_shadowPrimitives.clear()

      @_shadowPrimitives.drawEllipse(
        [0, aabb[3] / 4, aabb[2] / 2, aabb[3] / 4]
        Primitives.LineStyle color 0, 0, 0, .25
        Primitives.FillStyle color 0, 0, 0, .25
      )

      @_shadowPrimitives.setIsVisible @entity.hasShadow()
      @entity.on 'hasShadowChanged', =>
        @_shadowPrimitives.setIsVisible @entity.hasShadow()

    addToLocalContainer: (localContainer) ->

      localContainer.addChildAt @_shadowPrimitives, 0

    traitsChanged: ->

      @_snapPosition()
      @_snapRotation()

    positionChanged: -> @_snapPosition()

    rotationChanged: ->  @_snapRotation()

  _snapPosition: -> @_shadowPrimitives.setPosition @entity.position()

  _snapRotation: -> @_shadowPrimitives.setRotation @entity.rotation()
