

Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

FunctionExt = require 'avo/extension/function'
Vector = require 'avo/extension/vector'
Vertice = require 'avo/extension/vertice'

color = require 'avo/graphics/color'
Primitives = require 'avo/graphics/primitives'

Shape = require './index'

module.exports = class ShapeCircle extends Shape

  mixins = [
    VectorMixin 'position', 'x', 'y'
    Property 'radius', 0
  ]

  constructor: ->
    super

    mixin.call this for mixin in mixins

    @setType 'circle'

    @on [
      'parentOriginChanged', 'parentRotationChanged', 'parentScaleChanged'
      'originChanged', 'positionChanged', 'radiusChanged', 'rotationChanged', 'scaleChanged'
    ], =>
      @_primitives.clear()

      origin = Vector.add @parentOrigin(), @origin()
      rotation = @parentRotation() + @rotation()
      scale = @parentScale() * @scale()

      @_translatedPosition = Vertice.translate(
        @position(), origin, rotation, scale
      )

      @_primitives.drawCircle(
        origin, 2
        Primitives.LineStyle color 0, 0, 255
      )

      @_primitives.drawRectangle(
        @aabb()
        Primitives.LineStyle color 255, 255, 0
      )

      @_primitives.drawCircle(
        @_translatedPosition
        @radius() * @parentScale() * @scale()
        Primitives.LineStyle color 255, 255, 255
      )

      @emit 'aabbChanged'

  FunctionExt.fastApply Mixin, [@::].concat mixins

  aabb: (direction) ->

    radius = @radius() * @parentScale() * @scale()

    [
      @_translatedPosition[0] - radius
      @_translatedPosition[1] - radius
      radius * 2
      radius * 2
    ]

  fromObject: (O) ->
    super

    @setPosition O.position if O.position?
    @setRadius O.radius if O.radius?

    this

  toJSON: ->

    O = super

    O.position = @position()
    O.radius = @radius()

    O
