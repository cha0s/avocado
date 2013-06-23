
String = require 'Extension/String'

module.exports = (
	size = 'size'
	width = 'width'
	height = 'height'
) -> class
	
	_size = "_#{size}"
	
	@::[_size] = [0, 0]
	
	constructor: -> @[_size] = [0, 0]
		
	@::[size] = -> @[_size]
	@::[String.setterName size] = (position) -> @[_size] = position
	
	@::[width] = -> @[_size][0]
	@::[String.setterName width] = (width) -> @[_size][0] = width

	@::[height] = -> @[_size][1]
	@::[String.setterName height] = (height) -> @[_size][1] = height
	