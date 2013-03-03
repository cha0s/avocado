
DisplayCommand = require 'Graphics/DisplayCommand'
Font = require('Graphics').Font
upon = require 'Utility/upon'

Font.FontStyle_Regular   = 0
Font.FontStyle_Bold      = 1
Font.FontStyle_Italic    = 2
Font.FontStyle_Underline = 4

# Load a font at the specified URI.
Font.load = (uri) ->

	defer = upon.defer()
	
	unless uri?
		
		defer.resolve()
		return defer.promise
	
	Font['%load'] uri, defer.resolve
	
	defer.promise

Font::render = (position, destination, text, clip = [0, 0, 0, 0]) ->
	return unless position? and destination? and text?
	
	@['%render'] position, destination, text, clip

Font::setSize = (size) ->
	return unless size?
	
	@['%setSize'] size

Font::setStyle = (style) ->
	return unless style?
	
	@['%setStyle'] style

Font::textHeight = Font::['%textHeight']

Font::textWidth = Font::['%textWidth']

Font::textSize = (text) -> [@textWidth(), @textHeight()]
	
Font.DisplayCommand = class extends DisplayCommand
	
	constructor: (list, font, text, rectangle = [0, 0, 0, 0]) ->
		super list, rectangle
		
		@font_ = font
		@setText text
		
	setText: (text) ->
		
		oldText = @text_
		@text_ = text
		
		if oldText isnt @text_
			
			@setSize @font_.textSize text
			@markAsDirty()
		
	render: (position, clip, destination) ->
		
		@font_.render position, destination, @text_, clip
	