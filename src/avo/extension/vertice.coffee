# Vertice operations.

# **Vector** is a utility class to help with vertice operations. A vector
# is implemented as a 2-element array. Element 0 is *x* and element 1 is *y*.

module.exports = Vertice =

  # Translate a vertice from an origin point using rotation and scale.
  translate: (vertice, origin, rotation = 0, scale = 1) ->

  	difference = [vertice[0] - origin[0], vertice[1] - origin[1]]

  	rotation += Math.atan2 difference[1], difference[0]

  	magnitude = scale * Math.sqrt(
  		difference[0] * difference[0] + difference[1] * difference[1]
  	)

  	[
  		origin[0] + Math.cos(rotation) * magnitude
  		origin[1] + Math.sin(rotation) * magnitude
  	]
