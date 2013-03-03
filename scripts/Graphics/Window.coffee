# SPI proxy and constant definitions.

# **Window** handles window creation and properties of the window. 

EventEmitter = require 'Utility/EventEmitter'
Mixin = require 'Utility/Mixin'

NativeWindow = require('Graphics').Window
Window = class
	
	# Window creation constants.
	# 
	# * <code>Window.Flags_Default</code>: ***(default)*** Nothing special.
	# * <code>Window.Flags_Fullscreen</code>: Create a fullscreen window.
	# ***NOTE:*** May not be supported on all platforms.
	@Flags_Default = 0
	@Flags_Fullscreen = 1
	
	# Mouse and keycode constants.
	@Mouse = Object.freeze NativeWindow.Mouse
	@KeyCode = Object.freeze NativeWindow.KeyCode
	
	constructor: ->
		
		@window_ = new NativeWindow()
		
		Mixin @window_, EventEmitter

	# Show the window.
	display: -> @window_['%display']()
	
	# The height of the window.
	height: -> @size()[1]
	
	off: -> @window_.off.apply @window_, arguments
	on: ->@window_.on.apply @window_, arguments
	emit: -> @window_.emit.apply @window_, arguments
	
	# Poll for events sent to this window.
	pollEvents: -> @window_['%pollEvents']()
	
	# Render an Image onto this window.
	render: (image, rectangles = [[0, 0, 0, 0]]) ->
		return unless image?
		
		@window_['%render'] image, rectangle for rectangle in rectangles
	
	# Set the window parameters.
	setFlags: (flags = Window.Flags_Default) ->
		return unless flags?
		
		@window_['%setFlags'] flags
	
	# Set the window parameters.
	setSize: (size) ->
		return unless size?
		
		@window_['%setSize'] size
	
	# Set whether the mouse is visible while hovering over the window.
	setMouseVisibility: (visibility) ->
		return unless visibility?
		
		@window_['%setMouseVisibility'] visibility
	
	# Set the window title.
	setWindowTitle: (window, iconified = window) ->
		return unless window?
		
		@window_['%setWindowTitle'] window, iconified
	
	# The size of the window.
	size: -> @window_['%size']()
	
	# The width of the window.
	width = -> @size()[0]
	
require('Graphics').Window = Window
