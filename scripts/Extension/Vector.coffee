# Vector operations.

# **Vector** is a utility class to help with vector operations. A vector
# is implemented as a 2-element array. Element 0 is *x* and element 1 is *y*.

_ = require 'Utility/underscore'

module.exports = Vector = 

	# Scale a vector. This multiplies *x* and *y* by **k**.
	#
	#     avocado> Vector.scale [.5, 1.5], 2
	#     [1, 3]
	scale: (vector, k) -> [vector[0] * k, vector[1] * k]
	
	# Add two vectors.
	#
	#     avocado> Vector.add [1, 2], [1, 1]
	#     [2, 3]
	add: (l, r) -> [l[0] + r[0], l[1] + r[1]]
	
	# Subtract two vectors. 
	#
	#     avocado> Vector.sub [9, 5], [5, 2]
	#     [4, 3]
	sub: (l, r) -> [l[0] - r[0], l[1] - r[1]]
	
	# Multiply two vectors. 
	#
	#     avocado> Vector.mul [3, 5], [5, 5]
	#     [15, 25]
	mul: (l, r) -> [l[0] * r[0], l[1] * r[1]]
	
	# Divide two vectors. 
	#
	#     avocado> Vector.div [15, 5], [5, 5]
	#     [3, 1]
	div: (l, r) -> [l[0] / r[0], l[1] / r[1]]
	
	# Modulo divide two vectors. 
	#
	#     avocado> Vector.mod [13, 6], [5, 5]
	#     [3, 1]
	mod: (l, r) -> [l[0] % r[0], l[1] % r[1]]
	
	# Get the cartesian distance between two point vectors.
	#
	#     avocado> Vector.cartesianDistance [0, 0], [1, 1]
	#     1.4142135623730951
	cartesianDistance: (l, r) ->
		
		xd = l[0] - r[0]
		yd = l[1] - r[1]

		Math.sqrt xd * xd + yd * yd
	
	# Get the minimum values from two vectors.
	#
	#     avocado> Vector.min [-10, 10], [0, 0]
	#     [-10, 0]
	min: (l, r) ->
		
		[
			Math.min l[0], r[0]
			Math.min l[1], r[1]
		]
	
	# Get the maximum values from two vectors.
	#
	#     avocado> Vector.max [-10, 10], [0, 0]
	#     [0, 10]
	max: (l, r) ->
		
		[
			Math.max l[0], r[0]
			Math.max l[1], r[1]
		]
	
	# Clamp a vector's axes using a min vector and a max vector.
	#
	#     avocado> Vector.clamp [-10, 10], [0, 0], [5, 5]
	#     [0, 5]
	clamp: (vector, min, max) -> Vector.min max, Vector.max min, vector
	
	# Returns a deep copy of the vector.
	#
	#     avocado> vector = [0, 0]
	#     avocado> otherVectory Vector.copy vector
	#     avocado> vector is otherVector
	#     false
	copy: (vector) -> [vector[0], vector[1]]
	
	# Check whether a vector equals another vector.
	#
	#     avocado> Vector.equals [4, 4], [5, 4]
	#     false
	#
	#     avocado> Vector.equals [4, 4], [4, 4]
	#     true
	equals: (l, r) -> l[0] is r[0] and l[1] is r[1]
	
	# Checks whether a vector is [0, 0].
	#
	#     avocado> Vector.zero [0, 0]
	#     true
	#
	#     avocado> Vector.zero [0, 1]
	#     false
	isZero: (vector) ->
		
		vector[0] is 0 and vector[1] is 0
	
	# Round both axes of a vector.
	#
	#     avocado> Vector.round [3.14, 4.70]
	#     [3, 5]
	round: (vector) ->
		
		[
			Math.round vector[0]
			Math.round vector[1]
		]
	
	# Get the dot product of two vectors.
	#
	#     avocado> Vector.dot [2, 3], [4, 5]
	#     23
	dot: (l, r) -> l[0] * r[0] + l[1] * r[1]
	
	projected: (vector, direction, noNeg) ->
		
		projected = switch direction
			when 0, 2 then vector
			when 1, 3 then [vector[1], vector[0]]
		
		unless noNeg
			switch direction
				when 1 then projected[0] *= -1
				when 2, 3 then projected[1] *= -1
					
		projected
	
	# Get a hypotenuse unit vector. If an origin vector is passed in, the
	# hypotenuse is derived from the distance to the origin.
	#
	#     avocado> Vector.hypotenuse [5, 5], [6, 7]
	#     [-0.4472135954999579, -0.8944271909999159]
	#
	#     avocado> Vector.hypotenuse [.5, .7]
	#     [0.5812381937190965, 0.813733471206735]
	hypotenuse: (unitOrDestination, origin) ->
		
		distanceOrUnit = unitOrDestination
		distanceOrUnit = Vector.sub distanceOrUnit, origin if origin?
		
		return [0, 0] if 0 is dp = Vector.dot distanceOrUnit, distanceOrUnit
		hypotenuse = Vector.scale(
			distanceOrUnit
			1 / Math.sqrt dp
		)
		
		# Don't let NaN poison our equations.
		[
			if NaN is hypotenuse[0] then 0 else hypotenuse[0]
			if NaN is hypotenuse[1] then 0 else hypotenuse[1]
		]
	
	# Get the absolute values of the axes of a vector.
	#
	#     avocado> Vector.abs [23, -5.20]
	#     [23, 5.20]
	abs: (vector) ->
		
		[
			Math.abs vector[0]
			Math.abs vector[1]
		]

	# Floor both axes of a vector.
	#
	#     avocado> Vector.floor [3.14, 4.70]
	#     [3, 4]
	floor: (vector) ->
		
		[
			Math.floor vector[0]
			Math.floor vector[1]
		]

	# Get the area a vector.
	#
	#     avocado> Vector.area [3, 6]
	#     18
	area: (vector) -> vector[0] * vector[1]

	# Checks whether a vector is null. A vector is null if either axis is 0.
	# The algorithm prefers horizontal directions to vertical; if you move
	# up-right or down-right you'll face right.
	#
	#     avocado> Vector.isNull [1, 0]
	#     true
	#
	#     avocado> Vector.isNull [1, 1]
	#     false
	isNull: (vector) ->
		return true unless vector?
		return true unless vector.length is 2
		
		vector[0] is 0 or vector[1] is 0
	
	# Convert a vector to a 4-direction. A 4-direction is:
	# 
	# * 0: Up
	# * 1: Right
	# * 2: Down
	# * 3: Left
	#
	#     avocado> Vector.toDirection4 [0, 1]
	#     2
	#
	#     avocado> Vector.toDirection4 [1, 0]
	#     1
	toDirection4: (vector) ->
		
		vector = Vector.hypotenuse vector
		
		#  */

		sqrt_2_2 = Math.sqrt(2) / 2

		x = Math.abs(vector[0]) - sqrt_2_2
		if x > 0 and x < sqrt_2_2
			return if vector[0] > 0 then 1 else 3
		
		return if vector[1] > 0 then 2 else 0
	
	# Convert a vector to an 8-direction. An 8-direction is:
	# 
	# * 0: Up
	# * 1: Right
	# * 2: Down
	# * 3: Left
	# * 4: Up-Right
	# * 5: Down-Right
	# * 6: Down-Left
	# * 7: Up-Left
	#
	#     avocado> Vector.toDirection8 [1, 1]
	#     5
	#
	#     avocado> Vector.toDirection8 [1, 0]
	#     1
	toDirection8: (vector) ->
		
		vector = Vector.hypotenuse vector

		twoPi = Math.PI * 2
		
		# Orient radians
		rad = (twoPi + Math.atan2(vector[1], vector[0])) % twoPi
		rad = (rad + (Math.PI * .5)) % twoPi
		
		rad = Math.floor(rad * 100000) / 100000
		
		ds = [0, 4, 1, 5, 2, 6, 3, 7]
		r = twoPi - Math.PI * 0.125
		for i in ds
			
			nr = (r + (Math.PI/4)) % twoPi
			nr = Math.floor(nr * 100000) / 100000
			
			return i if rad >= r && rad < nr
			
			r = nr
		
		return 0
	
	# Convert a vector to a *directionCount*-direction.
	#
	#     avocado> Vector.toDirection [0, 1], 4
	#     2
	toDirection: (vector, directionCount) ->
		
		switch directionCount
			
			when 1 then 0
			when 4 then Vector.toDirection4 vector
			when 8 then Vector.toDirection8 vector
			else
				throw new Error "Unsupported conversion of vector to #{directionCount}-direction."
	
	fromDirection: (direction) ->
		
		switch direction
			
			when 0 then [0, -1]
			when 1 then [1, 0]
			when 2 then [0, 1]
			when 3 then [-1, 0]
			when 4 then @hypotenuse [1, -1]
			when 5 then @hypotenuse [1, 1]
			when 6 then @hypotenuse [-1, 1]
			when 7 then @hypotenuse [-1, -1]
	
	# Convert a vector to an object.
	#
	#     avocado> Vector.toObject [3, 4]
	#     {x: 3, y: 4}
	toObject: (vector) -> x: vector[0], y: vector[1]
	
	# Mix the vector methods into a vector instance.
	#
	#     avocado> v = Vector.mixin [3, 4]
	#     avocado> v.add [4, 5]
	#     [7, 9]
	mixin: (v) ->
		
		for own method, f of Vector
			continue if _.contains ['mixin'], method
			
			v[method] = _.bind f, v, v
		
		v[method] = _.compose Vector.mixin, v[method] for method in [
			'scale', 'add', 'sub', 'div', 'copy', 'isZero', 'round', 'floor'
			'isNull', 'mul', 'equals'
		]
			
		v
