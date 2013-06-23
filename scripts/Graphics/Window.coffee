# SPI proxy and constant definitions.

# **Window** handles window creation and properties of the window. 

EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'

Window = require('Graphics').Window

Mixin(
	Window.prototype
	EventEmitter
)

# Window creation constants.
# 
# * <code>Window.Flags_Default</code>: ***(default)*** Nothing special.
# * <code>Window.Flags_Fullscreen</code>: Create a fullscreen window.
# ***NOTE:*** May not be supported on all platforms.
Window.Flags_Default = 0
Window.Flags_Fullscreen = 1

# Mouse and keycode constants.
Window.Mouse = Object.freeze Window.Mouse
Window.KeyCode = Object.freeze Window.KeyCode

# Show the window.
Window::display = -> @['%display']()

# The height of the window.
Window::height = -> @size()[1]

# Poll for events sent to this window.
Window::pollEvents = -> @['%pollEvents']()

# Render an Image onto this window.
Window::render = (image, rectangle = [0, 0, 0, 0]) ->
	return unless image?
	
	@['%render'] image, rectangle

# Set the window parameters.
Window::setFlags = (flags = Window.Flags_Default) ->
	return unless flags?
	
	@['%setFlags'] flags

# Set the window parameters.
Window::setSize = (size) ->
	return unless size?
	
	@['%setSize'] size

# Set whether the mouse is visible while hovering over the window.
Window::setMouseVisibility = (visibility) ->
	return unless visibility?
	
	@['%setMouseVisibility'] visibility

# Set the window title.
Window::setWindowTitle = (window, iconified = window) ->
	return unless window?
	
	@['%setWindowTitle'] window, iconified

# The size of the window.
Window::size = -> @['%size']()

# The width of the window.
Window::width = -> @size()[0]
