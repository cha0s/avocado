
Vector = require 'Extension/Vector'

module.exports =

	lerp: (actual, lerping, easing = 0) ->
		
		return actual if easing is 0
		
		distance = Vector.cartesianDistance(
			actual
			lerping
		)
		return actual if distance is 0
		
		Vector.add(
			lerping
			Vector.scale(
				Vector.hypotenuse(
					actual
					lerping
				)
				if distance is 0
					0
				else
					distance / easing
			)
		)