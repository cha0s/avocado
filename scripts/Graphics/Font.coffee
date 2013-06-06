
Font = require('Graphics').Font
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'

Font.FontStyle_Regular   = 0
Font.FontStyle_Bold      = 1
Font.FontStyle_Italic    = 2
Font.FontStyle_Underline = 4

# Load a font at the specified URI.
Font.load = (uri) ->

	unless uri?
		return Q.reject new Error 'Attempted to load Font with a null URI.'
	
	deferred = Q.defer()
	Font['%load'] uri, deferred.makeNodeResolver()
	deferred.promise

Font::render = (
	position
	text
	destination
	r, g, b, a = 1
	clip = Rectangle.compose(
		[0, 0]
		@textSize text
	)
) ->
	return unless position? and destination? and text? and r? and g? and b?
	
	@['%render'] position, text, destination, r, g, b, a, clip

Font::setSize = (size) ->
	return unless size?
	
	@['%setSize'] size

Font::setStyle = (style) ->
	return unless style?
	
	@['%setStyle'] style

Font::textHeight = Font::['%textHeight']

Font::textWidth = Font::['%textWidth']

Font::textSize = (text) -> [
	@textWidth text
	@textHeight text
]
