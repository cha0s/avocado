
module.exports = class

	@::_size = []
	
	constructor: ->
		
		@_size = [0, 0]
		
	size: -> @_size
	setSize: (position) -> @_size = position
	
	width: -> @_size[0]
	setWidth: (width) -> @_size[0] = width

	height: -> @_size[1]
	setHeight: (height) -> @_size[1] = height
	