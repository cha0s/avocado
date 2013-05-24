
Vector = require 'Extension/Vector'

exports.Image = class
	
	constructor: (@_size = [0, 0]) ->
	
	size: -> Vector.copy @_size
	width: -> @_size[0]
	height: -> @_size[1]
