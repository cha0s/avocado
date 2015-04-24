
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

FunctionExt = require 'avo/extension/function'
Vector = require 'avo/extension/vector'

Shape = require './index'
ShapePolygon = require './polygon'

module.exports = class ShapeRectangle extends ShapePolygon

  mixins = [
  	VectorMixin 'position', 'x', 'y'
  	VectorMixin 'size', 'width', 'height'
  ]

  constructor: ->
  	super

  	mixin.call this for mixin in mixins

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

  FunctionExt.fastApply Mixin, [@::].concat mixins

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
