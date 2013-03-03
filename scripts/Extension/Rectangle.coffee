# Rectangle operations.

# **Rectangle** is a utility class to help with rectangle operations. A
# rectangle is implemented as a 4-element array. Element 0 is *x*, element
# 1 is *y*, element 2 is *width* and element 3 is *height*.

_ = require 'Utility/underscore'
Vector = require 'Extension/Vector'

module.exports = Rectangle = 

	# Check if a rectangle intersects with another rectangle.
	#
	#     avocado> Rectangle.intersects [0, 0, 16, 16], [8, 8, 24, 24]
	#     true
	#
	#     avocado> Rectangle.intersects [0, 0, 16, 16], [16, 16, 32, 32]
	#     false
	intersects: (l, r) ->
	
		return false if l[0] >= r[0] + r[2]
		return false if r[0] >= l[0] + l[2]
		return false if l[1] >= r[1] + r[3]
		return false if r[1] >= l[1] + l[3]
		
		true
		
	isTouching: (rectangle, vector) ->
		
		Rectangle.intersects(
			rectangle
			Rectangle.compose vector, [1, 1]
		)

	# Compose a rectangle from a position vector and a size vector.
	#
	#     avocado> Rectangle.compose [0, 0], [16, 16]
	#     [0, 0, 16, 16]
	compose: (l, r) ->
		
		l.concat r
		
	# Make a deep copy of the rectangle.
	#
	#     avocado> rectangle = [0, 0, 16, 16]
	#     avocado> rectangle is Rectangle.copy rectangle
	#     false
	copy: (rectangle) -> [rectangle[0], rectangle[1], rectangle[2], rectangle[3]]
	
	# Convert a rectangle to an object. If you *useShortKeys*, The width and
	# height keys will be named w and h, respectively. 
	#
	#     avocado> Rectangle.toObject [3, 4, 5, 6]
	#     {x: 3, y: 4, width: 5, height: 6}
	#
	#     avocado> Rectangle.toObject [3, 4, 5, 6], true
	#     {x: 3, y: 4, w: 5, h: 6}
	toObject: (rectangle, useShortKeys = false) ->
		
		whKeys = if useShortKeys then ['w', 'h'] else ['width', 'height']
		
		O = 
			x: rectangle[0]
			y: rectangle[1]
		O[whKeys[0]] = rectangle[2]
		O[whKeys[1]] = rectangle[3]
		O

	# Returns the position of a rectangle.
	#
	#     avocado> Rectangle.position [8, 8, 16, 16]
	#     [8, 8]
	position: (rectangle) ->
		
		[
			rectangle[0]
			rectangle[1]
		]
	
	# Returns the size of a rectangle.
	#
	#     avocado> Rectangle.position [8, 8, 16, 16]
	#     [16, 16]
	size: (rectangle) ->
		
		[
			rectangle[2]
			rectangle[3]
		]
	
	# Compute the intersection rectangle of two rectangles.
	#
	#     avocado> Rectangle.intersection [0, 0, 16, 16], [8, 8, 24, 24]
	#     [8, 8, 8, 8]
	intersection: (l,r) ->
		
		return [0, 0, 0, 0] unless Rectangle.intersects l, r
		
		x = Math.max l[0], r[0]
		y = Math.max l[1], r[1]
		
		lx2 = l[0] + l[2]
		rx2 = r[0] + r[2]
		ly2 = l[1] + l[3]
		ry2 = r[1] + r[3]
		
		w = (if lx2 <= rx2 then lx2 else rx2) - x
		h = (if ly2 <= ry2 then ly2 else ry2) - y
		
		[x, y, w, h]

	# Returns a rectangle translated along the [*x*, *y*] axis of a vector.
	#
	#     avocado> Rectangle.translated [0, 0, 16, 16], [8, 8]
	#     [8, 8, 16, 16]
	translated: (rectangle, vector) ->
		
		Rectangle.compose(
			Vector.add vector, Rectangle.position rectangle
			Rectangle.size rectangle
		)
		
	# Checks if a rectangle is null. A null rectangle is defined by having any
	# 0-length axis.
	#
	#     avocado> Rectangle.isNull [0, 0, 1, 1]
	#     false
	#
	#     avocado> Rectangle.isNull [0, 0, 1, 0]
	#     true
	isNull: (rectangle) -> Vector.isNull Rectangle.size rectangle
	
	# Check whether a rectangle equals another rectangle.
	#
	#     avocado> Rectangle.equals [0, 0, 0, 0], [0, 0, 0, 1]
	#     false
	#
	#     avocado> Rectangle.equals [0, 0, 0, 0], [0, 0, 0, 0]
	#     true
	equals: (l, r) ->
		
		l[0] is r[0] and l[1] is r[1] and l[2] is r[2] and l[3] is r[3]

	# Returns a rectangle that is the united area of two rectangles.
	#
	#     avocado> Rectangle.united [0, 0, 4, 4], [4, 4, 8, 8]
	#     [0, 0, 12, 12]
	united: (l, r) ->
		
		return r if Rectangle.isNull l
		return l if Rectangle.isNull r
		
		x = Math.min l[0], r[0]
		y = Math.min l[1], r[1]
		x2 = Math.max l[0] + l[2], r[0] + r[2]
		y2 = Math.max l[1] + l[3], r[1] + r[3]
		
		united = [
			x
			y
			x2 - x
			y2 - y
		]
		
	# Round the position and size of a rectangle.
	#
	#     avocado> Rectangle.round [3.14, 4.70, 5.32, 1.8]
	#     [3, 5, 5, 2]
	round: (rectangle) ->
		
		Rectangle.compose(
			Vector.round Rectangle.position rectangle
			Vector.round Rectangle.size rectangle
		)
		
	# Floor the position and size of a rectangle.
	#
	#     avocado> Rectangle.floor [3.14, 4.70, 5.32, 1.8]
	#     [3, 4, 5, 1]
	floor: (rectangle) ->
		
		Rectangle.compose(
			Vector.floor Rectangle.position rectangle
			Vector.floor Rectangle.size rectangle
		)
		
	# Mix the rectangle methods into a rectangle instance.
	#
	#     avocado> r = Rectangle.mixin [3, 4, 5, 6]
	#     avocado> r.size()
	#     [5, 6]
	mixin: (r) ->
		
		for own method, f of Rectangle
			continue if _.contains ['mixin', 'compose'], method
			
			r[method] = _.bind f, r, r
		
		r[method] = _.compose Vector.mixin, r[method] for method in [
			'position', 'size'
		]
			
		r[method] = _.compose Rectangle.mixin, r[method] for method in [
			'intersection', 'translated', 'united', 'round', 'floor'
		]
			
		r
