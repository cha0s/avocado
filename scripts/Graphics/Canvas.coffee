# SPI proxy and constant definitions.

# **Canvas** handles primitive operations such as filling, line, circle,
# box drawing and rasterization. 

Canvas = require('Graphics').Canvas
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

# Draw mode constants.
# 
# * <code>Canvas.DrawMode_Replace</code>: Write over any graphics under this
# image when rendering.
# * <code>Canvas.DrawMode_Blend</code>: ***(default)*** Blend the image with
# any graphics underneath using alpha pixel values.
Canvas.DrawMode_Replace = 0
Canvas.DrawMode_Blend   = 1

# Calculate the pixel value of two pixels blended together with alpha.
Canvas.blendPixel = (src, dst, alpha = 255) ->
	return unless src? and dst?
	
	# If source alpha is 0, then use the destination.
	{sr, sg, sb, sa} = Rgba src
	return dst unless sa > 0
	
	# Calculate the source pixel alpha.
	pAlpha = sa * (alpha / 255)
	
	# Do the [alpha blending](http://en.wikipedia.org/wiki/Alpha_compositing#Alpha_blending).
	{dr, dg, db, da} = Rgba dst
	dr = (sr * pAlpha + dr * (255 - pAlpha)) / 255
	dg = (sg * pAlpha + dg * (255 - pAlpha)) / 255
	db = (sb * pAlpha + db * (255 - pAlpha)) / 255
	da = pAlpha
	
	# Shift the pixel colors back into a single 32-bit integer.
	Rgba dr, dg, db, da

# Show the image.
Canvas::display = Canvas::['%display']

# Draw a circle at the given position with the given radius. Draw it with the given
# RGBA color, and with the given draw mode.
Canvas::drawCircle = (position, radius, r, g, b, a = 255, mode = Canvas.DrawMode_Blend) ->
	return unless position? and radius? and r? and g? and b?
	
	@['%drawCircle'] position, radius, r, g, b, a, mode

# Draw a filled box at the given x, y with the given width, height dimensions.
# Draw it with the given RGBA color, and with the given draw mode.	
Canvas::drawFilledBox = (box, r, g, b, a = 255, mode = Canvas.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawFilledBox'] box, r, g, b, a, mode

# Draw a line at the given x, y to the x2, y2. Draw it with the given RGBA
# color, and with the given draw mode.
Canvas::drawLine = (line, r, g, b, a = 255, mode = Canvas.DrawMode_Blend) ->
	return unless line? and r? and g? and b?
	
	@['%drawLine'] line, r, g, b, a, mode
	
# Draw a box at the given x, y with the given width, height dimensions. Draw it
# with the given RGBA color, and with the given draw mode.
Canvas::drawLineBox = (box, r, g, b, a = 255, mode = Canvas.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawLineBox'] box, r, g, b, a, mode
	
# Fill with a specified color.
Canvas::fill = (r, g, b, a = 255) ->
	return unless r? and g? and b?
	
	@['%fill'] r, g, b, a

# Get the height of the image.	
Canvas::height = Canvas::['%height']

Canvas::lockPixels = -> @['%lockPixels']?()

# Get the pixel color at a given x, y coordinate.
Canvas::pixelAt = (x, y) ->
	return unless x? and y?
	
	@['%pixelAt'] x, y
	
# Render this image at x, y onto another image with the given alpha blending
# and draw mode, using the given sx, sy, sw, sh source rectangle to clip.
Canvas::render = (position, destination, alpha = 255, mode = Canvas.DrawMode_Blend, sourceRect = [0, 0, 0, 0]) ->
	return unless position? and destination?
	
	@['%render'] position, destination, alpha, mode, sourceRect

# Save this image to a file. The filename will be qualified to the resource
# path. It is currently not allowed to save images outside of the resource
# path.
Canvas::saveToFile = (filename) ->
	return unless filename?
	
	@['%saveToFile'] filename

# Set the pixel color at a given x, y coordinate.	
Canvas::setPixelAt = (x, y, color) ->
	return unless x? and y? and color?
	
	@['%setPixelAt'] x, y, color
	
# Get the size of the image.
Canvas::size = -> [@width(), @height()]

Canvas::unlockPixels = -> @['%unlockPixels']?()

# Get the URI (if any) used to load this image.
Canvas::uri = Canvas::['%uri']

# Get the width of the image.
Canvas::width = Canvas::['%width']
