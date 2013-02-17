# SPI proxy and constant definitions.

# **Image** handles image resource management. Primitive operations such
# as filling, line, circle, box drawing and rasterization are supported. All
# image resources are loaded through **Image**.load. 

DisplayCommand = require 'Graphics/DisplayCommand'
Image = require('Graphics').Image
Rectangle = require 'Extension/Rectangle'
upon = require 'Utility/upon'
Vector = require 'Extension/Vector'

# Draw mode constants.
# 
# * <code>Image.DrawMode_Replace</code>: Write over any graphics under this
# image when rendering.
# * <code>Image.DrawMode_Blend</code>: ***(default)*** Blend the image with
# any graphics underneath using alpha pixel values.
Image.DrawMode_Replace = 0
Image.DrawMode_Blend   = 1

# Calculate the pixel value of two pixels blended together with alpha.
Image.blendPixel = (src, dst, alpha = 255) ->
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

# Load an image at the specified URI.
Image.load = (uri) ->

	defer = upon.defer()
	
	unless uri?
		
		defer.resolve()
		return defer.promise
	
	Image['%load'] uri, defer.resolve
	
	defer.promise

# Show the image.
Image::display = Image::['%display']

# Draw a circle at the given position with the given radius. Draw it with the given
# RGBA color, and with the given draw mode.
Image::drawCircle = (position, radius, r, g, b, a = 255, mode = Image.DrawMode_Blend) ->
	return unless position? and radius? and r? and g? and b?
	
	@['%drawCircle'] position, radius, r, g, b, a, mode

# Draw a filled box at the given x, y with the given width, height dimensions.
# Draw it with the given RGBA color, and with the given draw mode.	
Image::drawFilledBox = (box, r, g, b, a = 255, mode = Image.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawFilledBox'] box, r, g, b, a, mode

# Draw a line at the given x, y to the x2, y2. Draw it with the given RGBA
# color, and with the given draw mode.
Image::drawLine = (line, r, g, b, a = 255, mode = Image.DrawMode_Blend) ->
	return unless line? and r? and g? and b?
	
	@['%drawLine'] line, r, g, b, a, mode
	
# Draw a box at the given x, y with the given width, height dimensions. Draw it
# with the given RGBA color, and with the given draw mode.
Image::drawLineBox = (box, r, g, b, a = 255, mode = Image.DrawMode_Blend) ->
	return unless box? and r? and g? and b?
	
	@['%drawLineBox'] box, r, g, b, a, mode
	
# Fill with a specified color.
Image::fill = (r, g, b, a = 255) ->
	return unless r? and g? and b?
	
	@['%fill'] r, g, b, a

# Get the height of the image.	
Image::height = Image::['%height']

Image::lockPixels = -> @['%lockPixels']?()

# Get the pixel color at a given x, y coordinate.
Image::pixelAt = (x, y) ->
	return unless x? and y?
	
	@['%pixelAt'] x, y
	
# Render this image at x, y onto another image with the given alpha blending
# and draw mode, using the given sx, sy, sw, sh source rectangle to clip.
Image::render = (position, destination, alpha = 255, mode = Image.DrawMode_Blend, sourceRect = [0, 0, 0, 0]) ->
	return unless position? and destination?
	
	@['%render'] position, destination, alpha, mode, sourceRect

# Save this image to a file. The filename will be qualified to the resource
# path. It is currently not allowed to save images outside of the resource
# path.
Image::saveToFile = (filename) ->
	return unless filename?
	
	@['%saveToFile'] filename

# Set the pixel color at a given x, y coordinate.	
Image::setPixelAt = (x, y, color) ->
	return unless x? and y? and color?
	
	@['%setPixelAt'] x, y, color
	
# Get the size of the image.
Image::size = -> [@width(), @height()]

Image::unlockPixels = -> @['%unlockPixels']?()

# Get the URI (if any) used to load this image.
Image::uri = Image::['%uri']

# Get the width of the image.
Image::width = Image::['%width']

Image.DisplayCommand = class extends DisplayCommand
	
	constructor: (list, image, rectangle = [0, 0, 0, 0]) ->
		
		if Vector.isNull Rectangle.size rectangle
			
			rectangle = Rectangle.compose(
				Rectangle.position rectangle
				image.size()
			)
		
		super list, rectangle
		
		@image_ = image
		
	render: (position, clip, destination) ->
		
		@image_.render(
			position
			destination
			255
			Image.DrawMode_Blend
			clip
		)

Image.FillDisplayCommand = class extends DisplayCommand
	
	constructor: (list, r, g, b, a = 255, rectangle = [0, 0, 0, 0]) ->
		super list, rectangle
		
		[@r_, @g_, @b_, @a_] = [r, g, b, a]
		
	render: (position, clip, destination) ->
		
		destination.drawFilledBox(
			Rectangle.compose(
				position
				Rectangle.size clip
			)
			@r_, @g_, @b_, @a_
		)
