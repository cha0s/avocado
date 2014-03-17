
FunctionExt = require 'Extension/Function'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
String = require 'Extension/String'

module.exports = Color = class

	mixins = [
		Property 'red', 0
		Property 'green', 0
		Property 'blue', 0
		Property 'alpha', 1
	]
	
	constructor: (r = 255, g = 0, b = 255, a = 1) ->
		
		mixin.call @ for mixin in mixins
		
		@setRed r
		@setGreen g
		@setBlue b
		@setAlpha a
			
	FunctionExt.fastApply Mixin, [@::].concat mixins

Color.Rgba = Rgba = (r, g, b, a) ->

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

Color.Rgb = (r, g, b) -> Rgba r, g, b, 255
