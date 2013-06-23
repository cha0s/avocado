
Rectangle = require 'Extension/Rectangle'
String = require 'Extension/String'

module.exports = (
	rectangle = 'rectangle'
	x = 'x'
	y = 'y'
	width = 'width'
	height = 'height'
	position = 'position'
	size = 'size'
) ->
	
	_rectangle = "_#{rectangle}"
	setPosition = "#{String.setterName position}"
	setRectangle = "#{String.setterName rectangle}"
	setSize = "#{String.setterName size}"
	
	class
	
		@::[_rectangle] = [0, 0, 0, 0]
		
		constructor: -> @[_rectangle] = [0, 0, 0, 0]
		
		@::[rectangle] = -> @[_rectangle]
		@::[setRectangle] = (rectangle) ->
			@[_rectangle] = rectangle
		
		@::[x] = -> @[_rectangle][0]
		@::["#{String.setterName x}"] = (x) ->
			r = @[_rectangle]
			@[setPosition] [x, r[1]]
	
		@::[y] = -> @[_rectangle][1]
		@::["#{String.setterName y}"] = (y) ->
			r = @[_rectangle]
			@[setPosition] [r[0], y]
	
		@::[position] = -> Rectangle.position @[_rectangle]
		@::["#{String.setterName position}"] = (position) ->
			r = @[_rectangle]
			@[setRectangle] [position[0], position[1], r[2], r[3]]
	
		@::[width] = -> @[_rectangle][2]
		@::["#{String.setterName width}"] = (width) ->
			r = @[_rectangle]
			@[setSize] [width, r[3]]
	
		@::[height] = -> @[_rectangle][3]
		@::["#{String.setterName height}"] = (height) ->
			r = @[_rectangle]
			@[setSize] [r[2], height]

		@::[size] = -> Rectangle.size @[_rectangle]
		@::["#{String.setterName size}"] = (size) ->
			r = @[_rectangle]
			@[setRectangle] [r[0], r[1], size[0], size[1]]
		