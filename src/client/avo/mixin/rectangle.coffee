
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
  meta = {}
) ->

  _setRectangle = String.setterName rectangle
  _setPosition = String.setterName position
  _setSize = String.setterName size

  class

    mixins = [
      PositionProperty = VectorMixin position, x, y, meta[position]
      SizeProperty = VectorMixin size, width, height, meta[size]
    ]

    constructor: -> mixin.call @ for mixin in mixins

    FunctionExt.fastApply Mixin, [@::].concat mixins

    @::[rectangle] = -> Rectangle.compose @[position](), @[size]()
    @::[_setRectangle] = (_rectangle) ->
      oldRectangle = @[rectangle]()
      PositionProperty::[_setPosition].call this, Rectangle.position _rectangle
      SizeProperty::[_setSize].call this, Rectangle.size _rectangle
      unless Rectangle.equals oldRectangle, _rectangle
        @emit? "#{rectangle}Changed", oldRectangle, _rectangle

    @::[_setPosition] = (_position) ->
      oldPosition = @[position]()
      @[_setRectangle] Rectangle.compose _position, @[size]()
      unless Vector.equals oldPosition, _position
        @emit? "#{position}Changed", oldPosition, _position

    @::[_setSize] = (_size) ->
      oldSize = @[size]()
      @[_setRectangle] Rectangle.compose @[position](), _size
      unless Vector.equals oldSize, _size
        @emit? "#{size}Changed", oldSize, _size
