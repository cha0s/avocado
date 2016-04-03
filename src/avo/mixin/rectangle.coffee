
FunctionExt = require 'avo/extension/function'
Mixin = require './index'
Rectangle = require 'avo/extension/rectangle'
String = require 'avo/extension/string'
Vector = require 'avo/extension/vector'
VectorMixin = require './vector'

module.exports = RectangleMixin = (
  rectangle = 'rectangle'
  x = 'x'
  y = 'y'
  width = 'width'
  height = 'height'
  position = 'position'
  size = 'size'
) ->

  _setRectangle = String.setterName rectangle
  _setPosition = String.setterName position
  _setSize = String.setterName size

  class

    mixins = [
      PositionProperty = VectorMixin position, x, y
      SizeProperty = VectorMixin size, width, height
    ]

    constructor: ->
      mixin.call @ for mixin in mixins

    FunctionExt.fastApply Mixin, [@::].concat mixins

    @::[rectangle] = -> Rectangle.compose @[position](), @[size]()
    @::[_setRectangle] = (_rectangle) ->
      oldRectangle = @[rectangle]()
      PositionProperty::[_setPosition].call this, Rectangle.position _rectangle
      SizeProperty::[_setSize].call this, Rectangle.size _rectangle
      @emit? "#{rectangle}Changed" unless Rectangle.equals oldRectangle, _rectangle

    @::[_setPosition] = (_position) ->
      oldPosition = @[position]()
      @[_setRectangle] Rectangle.compose _position, @[size]()
      @emit? "#{position}Changed" unless Vector.equals oldPosition, _position

    @::[_setSize] = (_size) ->
      oldSize = @[size]()
      @[_setRectangle] Rectangle.compose @[position](), _size
      @emit? "#{size}Changed" unless Vector.equals oldSize, _size
