exports.Rgba = Rgba = (r, g, b, a) ->

	# Passed in an integer, break it down into RGBA.
	if not g?
		
		a: r >>> 24
		r: (r >>> 16) & 255
		g: (r >>> 8) & 255
		b: r & 255
	
	else
	
		# The right shift at the end seems meaningless, but it's a clever way
		# to force JS to give us an unsigned number.
		((a << 24) | (r << 16) | (g << 8) | b) >>> 0

exports.Rgb = (r, g, b) -> Rgba r, g, b, 255
