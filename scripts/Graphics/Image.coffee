# SPI proxy and constant definitions.

# **Image** handles image resource management. 

Image = require('Graphics').Image
Q = require 'Utility/Q'

# Load an image at the specified URI.
Image.load = (uri) ->

	unless uri?
		return Q.reject new Error 'Attempted to load Image with a null URI.'
	
	deferred = Q.defer()
	Image['%load'] uri, deferred.makeNodeResolver()
	deferred.promise

# Get the height of the image.	
Image::height = Image::['%height']

# Get the size of the image.
Image::size = -> [@width(), @height()]

# Get the URI (if any) used to load this image.
Image::uri = Image::['%uri']

# Get the width of the image.
Image::width = Image::['%width']
