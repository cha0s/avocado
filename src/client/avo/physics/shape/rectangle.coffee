
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

Vector = require 'avo/extension/vector'

Shape = require './index'
ShapePolygon = require './polygon'

module.exports = Mixin.toClass [

  VectorMixin(
    'position', 'x', 'y'
    x: default: 0
    y: default: 0
  )

  VectorMixin(
    'size', 'width', 'height'
    width: default: 0
    height: default: 0
  )

], class ShapeRectangle extends ShapePolygon

  constructor: ->
    super

    @setType 'rectangle'

    @on [
      'positionChanged', 'sizeChanged'
    ], =>

      position = @position()
      size = @size()

      @setVertices [
        position
        Vector.add position, [size[0] - 1, 0]
        Vector.add position, [size[0] - 1, size[1] - 1]
        Vector.add position, [0, size[1] - 1]
      ]

  fromObject: (O) ->
    Shape::fromObject.call this, O

    @setPosition O.position if O.position?
    @setSize O.size if O.size?

    this

  toJSON: ->

    O = Shape::toJSON.call this

    O.position = @position()
    O.size = @size()

    O
