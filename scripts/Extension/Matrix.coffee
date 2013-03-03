# Matrix operations.

# **Matrix** is a utility class to help with matrix operations. A
# matrix is implemented as an n-element array. Data is stored in row-major
# order.

_ = require 'Utility/underscore'
#Vector = require 'Extension/Vector'

module.exports = Matrix =
	
	size: (matrix) ->
		
		return 0 if 0 is matrix.length
		
		matrix.length * matrix[0].length

	sizeVector: (matrix) ->
		
		return [0, 0] if 0 is matrix.length
		
		[matrix[0].length, matrix.length] 

	equals: (l, r) ->
		
		return false unless l.length is r.length
		
		return true if l.length is 0
		
		return false unless l[0].length is r[0].length
	
		for lrow, y in l
			rrow = r[y]
			for lindex, x in lrow
				return false unless lindex is rrow[x]
				
		true
		
