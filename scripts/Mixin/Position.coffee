
module.exports = Position = class

	@::_position = []
	
	constructor: ->
		
		@_position = [0, 0]
		
	position: -> @_position
	setPosition: (position) -> @_position = position
	
	x: -> @_position[0]
	setX: (x) -> @_position[0] = x

	y: -> @_position[1]
	setY: (y) -> @_position[1] = y
	