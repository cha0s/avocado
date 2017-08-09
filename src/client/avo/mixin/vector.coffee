
FunctionExt = require 'avo/extension/function'
Mixin = require './index'
Property = require './property'
String = require 'avo/extension/string'
Vector = require 'avo/extension/vector'

module.exports = VectorMixin = (
  vector = 'vector'
  x = 'x'
  y = 'y'
  meta = {}
) ->

  _setVector = String.setterName vector
  _setX = String.setterName x
  _setY = String.setterName y

  Mixin.toClass [

    XProperty = Property x, meta[x] ? {}
    YProperty = Property y, meta[y] ? {}

  ], class VectorMixin

    @::[vector] = -> [@[x](), @[y]()]
    @::[_setVector] = (_vector) ->
      oldVector = @[vector]()
      XProperty::[_setX].call this, _vector[0]
      YProperty::[_setY].call this, _vector[1]
      unless Vector.equals oldVector, _vector
        @emit? "#{vector}Changed", oldVector, _vector

    @::[_setX] = (_x) ->
      oldX = @[x]()
      @[_setVector] [_x, @[y]()]
      @emit? "#{x}Changed", oldX, _x if oldX isnt _x

    @::[_setY] = (_y) ->
      oldY = @[y]()
      @[_setVector] [@[x](), _y]
      @emit? "#{y}Changed", oldY, _y if oldY isnt _y
