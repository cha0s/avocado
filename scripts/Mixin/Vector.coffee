
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
String = require 'Extension/String'
Vector = require 'Extension/Vector'

module.exports = VectorMixin = (
	vector = 'vector'
	x = 'x'
	y = 'y'
) ->
	
	_setVector = String.setterName vector
	_setX = String.setterName x
	_setY = String.setterName y
	
	class
	
		constructor: ->
			property.call this for property in properties
		
		properties = [
			XProperty = Property x, 0
			YProperty = Property y, 0
		]
		
		Mixin.apply null, [@::].concat properties
		
		@::[vector] = -> [@[x](), @[y]()]
		@::[_setVector] = (_vector) ->
			oldVector = @[vector]()
			XProperty::[_setX].call this, _vector[0]
			YProperty::[_setY].call this, _vector[1]
			@emit? "#{vector}Changed" unless Vector.equals oldVector, _vector
			
		@::[_setX] = (_x) ->
			oldX = @[x]()
			@[_setVector] _x, @[y]()
			@emit? "#{x}Changed" if oldX isnt _x
			
		@::[_setY] = (_y) ->
			oldY = @[y]()
			@[_setVector] @[x](), _y
			@emit? "#{y}Changed" if oldY isnt _y
