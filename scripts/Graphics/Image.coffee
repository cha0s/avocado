# SPI proxy and constant definitions.

# **Image** handles image resource management. Primitive operations such
# as filling, line, circle, box drawing and rasterization are supported. All
# image resources are loaded through **Image**.load. 

Image = require('Graphics').Image
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

# Draw mode constants.
# 
# * <code>Image.DrawMode_Replace</code>: Write over any graphics under this
# image when rendering.
# * <code>Image.DrawMode_Blend</code>: ***(default)*** Blend the image with
# any graphics underneath using alpha pixel values.
Image.DrawMode_Replace = 0
Image.DrawMode_Blend   = 1

# Load an image at the specified URI.
Image.load = (uri) ->

	unless uri?
		return Q.reject new Error 'Attempted to load Image with a null URI.'
	
	deferred = Q.defer()
	Image['%load'] uri, deferred.makeNodeResolver()
	deferred.promise

# Get the height of the image.	
Image::height = Image::['%height']

# Render this image at x, y onto another image with the given alpha blending
# and draw mode, using the given sx, sy, sw, sh source rectangle to clip.
Image::render = (position, destination, alpha = 255, mode = Image.DrawMode_Blend, sourceRect = [0, 0, 0, 0]) ->
	return unless position? and destination?
	
	@['%render'] position, destination, alpha, mode, sourceRect

# Get the size of the image.
Image::size = -> [@width(), @height()]

# Get the URI (if any) used to load this image.
Image::uri = Image::['%uri']

# Get the width of the image.
Image::width = Image::['%width']
