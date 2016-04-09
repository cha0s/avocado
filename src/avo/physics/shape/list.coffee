
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

FunctionExt = require 'avo/extension/function'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

color = require 'avo/graphics/color'
Container = require 'avo/graphics/container'
Primitives = require 'avo/graphics/primitives'

module.exports = class ShapeList

  mixins = [
    EventEmitter
    VectorMixin(
      'origin', 'originX', 'originY'
      originX: default: 0
      originY: default: 0
    )
    VectorMixin(
      'position', 'x', 'y'
      x: default: 0
      y: default: 0
    )
    Property 'rotation', default: 0
    Property 'scale', default: 1
  ]

  constructor: ->

    mixin.call this for mixin in mixins

    @_container = new Container()
    @_primitives = new Primitives()
    @_shapes = []

    @on 'positionChanged', =>

      @_container.setPosition @positionWithOrigin()

    @on 'aabbChanged', =>

      @_primitives.clear()

      @_primitives.drawRectangle(
        Rectangle.translated(
          @aabb()
          Vector.scale @positionWithOrigin(), -1
        )
        Primitives.LineStyle color 255, 0, 255
      )

    @on 'shapesChanged', =>

      @_container.removeAllChildren()

      @_container.addChild @_primitives

      for shape in @_shapes

        shape.on 'aabbChanged', => @emit 'aabbChanged'

        @_container.addChild shape.primitives()

    @on 'originChanged', =>
      for shape in @_shapes
        shape.setParentOrigin @origin()

    @on 'rotationChanged', =>
      for shape in @_shapes
        shape.setParentRotation @rotation()

    @on 'scaleChanged', =>
      for shape in @_shapes
        shape.setParentScale @scale()

  FunctionExt.fastApply Mixin, [@::].concat mixins

  fromObject: (O) ->

    @_shapes = []

    for shape in O.shapes
      ShapeType = require "avo/physics/shape/#{shape.type}"
      @_shapes.push (new ShapeType()).fromObject shape

    @setOrigin O.origin if O.origin?
    @setRotation O.rotation if O.rotation?
    @setScale O.scale if O.scale?

    @emit 'shapesChanged'

    this

  addShape: (shape) ->

    @_shapes.push shape

    @emit 'shapesChanged'

  aabb: (translated = true) ->

    return [0, 0, 0, 0] if @_shapes.length is 0

    min = [Infinity, Infinity]
    max = [-Infinity, -Infinity]

    for shape in @_shapes

      aabb = shape.aabb()

      min[0] = Math.min min[0], aabb[0]
      min[1] = Math.min min[1], aabb[1]
      max[0] = Math.max max[0], aabb[0] + aabb[2]
      max[1] = Math.max max[1], aabb[1] + aabb[3]

    Rectangle.translated(
      [
        min[0], min[1]
        max[0] - min[0], max[1] - min[1]
      ]
      @positionWithOrigin()
    )

  container: -> @_container

  intersects: (shapeList) ->

    return false if @_shapes.length is 0

    return false unless Rectangle.intersects @aabb(), shapeList.aabb()

    for shape in @_shapes
      for otherShape in shapeList._shapes
        if Rectangle.intersects(
          Rectangle.translated(
            shape.aabb()
            @positionWithOrigin()
          )
          Rectangle.translated(
            otherShape.aabb()
            shapeList.positionWithOrigin()
          )
        )
          return self: shape, other: otherShape

    false

  positionWithOrigin: -> Vector.sub @position(), @origin()

  removeAtIndex: (index) ->

    @_shapes.splice index, 1

    @emit 'shapesChanged'

  shapes: -> @_shapes

  toJSON: ->

    shapes: shape.toJSON() for shape in @_shapes
