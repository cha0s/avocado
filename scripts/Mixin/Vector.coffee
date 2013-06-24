
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
String = require 'Extension/String'

module.exports = Vector = (
	defaultValue = [0, 0]
	vector = 'vector'
	x = 'x'
	y = 'y'
) -> class
	
	constructor: ->
		Property.call this for Property in Properties
		@[_setVector] defaultValue
		
	Properties = [
		XProperty = Property x, 0
		YProperty = Property y, 0
	]
	
	Mixin.apply null, [@::].concat Properties
	
	_setVector = String.setterName vector
	_setX = String.setterName x
	_setY = String.setterName y
	
	@::[vector] = -> [@[x](), @[y]()]
	@::[_setVector] = (_vector) ->
		oldVector = @[vector]()
		XProperty::[_setX].call this, _vector[0]
		YProperty::[_setY].call this, _vector[1]
		@emit? "#{vector}Changed" if oldVector isnt _vector
		
	@::[_setX] = (_x) ->
		oldX = @[x]()
		@[_setVector] _x, @[y]()
		@emit? "#{x}Changed" if oldX isnt _x
		
	@::[_setY] = (_y) ->
		oldY = @[y]()
		@[_setVector] @[x](), _y
		@emit? "#{y}Changed" if oldY isnt _y
