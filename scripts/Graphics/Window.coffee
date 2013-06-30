# SPI proxy and constant definitions.

# **Window** handles window creation and properties of the window. 

Graphics = require 'Graphics'
Timing = require 'Timing'

EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Vector = require 'Extension/Vector'

Window = Graphics.Window

Window.mixins = [
	EventEmitter
]

Mixin.apply null, [Window::].concat Window.mixins

forwardCallToPrivate = (call) => PrivateScope.forwardCall(
	Window::, call, (-> Private), 'windowScope'
)
		
# Window creation constants.
# 
# * <code>Window.FlagsDefault</code>: ***(default)*** Nothing special.
# * <code>Window.FlagsFullscreen</code>: Create a fullscreen window.
# ***NOTE:*** May not be supported on all platforms.
Window.FlagsDefault = 0
Window.FlagsFullscreen = 1

# Mouse and keycode constants.
Window.Mouse = Object.freeze Window.Mouse
Window.KeyCode = Object.freeze Window.KeyCode

Window.new = (size, flags) ->
	
	_window = new Window()

	mixin.call _window for mixin in Graphics.Window.mixins
	PrivateScope.call _window, Private, 'windowScope'
	
	_window.setSize size if size?
	_window.setFlags flags if flags?
	
	_window

# Show the window.
Window::display = -> @['%display']()

# The height of the window.
Window::height = -> @size()[1]

forwardCallToPrivate 'playerTickMovement'

# Poll for events sent to this window.
Window::pollEvents = -> @['%pollEvents']()

forwardCallToPrivate 'registerPlayerMovement'

# Render an Image onto this window.
Window::render = (image, rectangle = [0, 0, 0, 0]) ->
	return unless image?
	
	@['%render'] image, rectangle

# Set the window parameters.
Window::setFlags = (flags = Window.FlagsDefault) ->
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

Private = class
	
	constructor: (_public) ->

		# We want to store how much a player is moving either with the
		# arrow keys or the joystick/gamepad.
		@movement = {}
		@keyCodeMap = {}
		@stickIndexMap = {}
		
		# Joystick movement.
		_public.on 'joyAxis.Avocado', ({stickIndex, axis, value}) =>
			return if axis > 1
			
			return unless (player = @stickIndexMap[stickIndex])?
			return unless m = @movement[player]
			
			if value > 0
				m.joyState[if axis is 0 then 1 else 2] = Math.abs value
			else if value < 0
				m.joyState[if axis is 0 then 3 else 0] = Math.abs value
			else
				if axis is 0
					m.joyState[1] = m.joyState[3] = 0
				else
					m.joyState[0] = m.joyState[2] = 0
			
			@registerMovement player
			
		# Keyboard movement started.
		_public.on 'keyDown.Avocado', ({code}) =>
			
			return unless (player = @keyCodeMap[code])?
			return unless m = @movement[player]
			
			m.keyState[m.keyCodes.indexOf code] = 1
			
			@registerMovement player
			
		# Keyboard movement stopped.
		_public.on 'keyUp.Avocado', ({code}) =>
		
			return unless (player = @keyCodeMap[code])?
			return unless m = @movement[player]
		
			m.keyState[m.keyCodes.indexOf code] = 0
			
			@registerMovement player
		
		# Mouse dragging is a bit of a higher-level concept. We'll
		# implement it using the low-level API.
		@buttons = {}
		@dragStartLocation = {}
		@mouseLocation = [0, 0]
		
		Mouse = Graphics.Window.Mouse
		
		# Start dragging when a button is clicked.
		_public.on 'mouseButtonDown.Avocado', ({button}) =>
			switch button
				when Mouse.ButtonLeft, Mouse.ButtonMiddle, Mouse.ButtonRight
					@dragStartLocation[button] = mouseLocation
					@buttons[button] = true
				
		# Stop dragging when a button is released.
		_public.on 'mouseButtonUp.Avocado', ({button}) =>
			switch button
				when Mouse.ButtonLeft, Mouse.ButtonMiddle, Mouse.ButtonRight
					delete @buttons[button]
					delete @dragStartLocation[button]
		
		# When the mouse moves,
		_public.on 'mouseMove.Avocado', ({x, y}) =>
			mouseLocation = [x, y]
			
			# Check if any buttons are being held down
			keys = Object.keys @buttons
			if keys.length > 0
				
				# If so, send a mouseDrag event for each of them.
				for key in keys
					_window.emit(
						'mouseDrag'
							position: mouseLocation
							button: parseInt key
							relative: Vector.sub(
								mouseLocation
								@dragStartLocation[key]
							)
					)

	# Get a unit movement vector for a player.
	playerTickMovement: (player) ->
		
		return [0, 0] unless @movement[player]?
		
		@movement[player].unit
	
	# We'll store any movement that comes in, combining keyboard and
	# joystick movement, making sure that combined they never exceed 1.
	registerMovement: (player) ->
		
		m = @movement[player]
		m.unit = [
			Math.max(
				Math.min(
					(
						m.keyState[1] - m.keyState[3]
					) + (
						m.joyState[1] - m.joyState[3]
					)
					1
				)
				-1
			)
			Math.max(
				Math.min(
					(
						m.keyState[2] - m.keyState[0]
					) + (
						m.joyState[2] - m.joyState[0]
					)
					1
				)
				-1
			)
		]
		m.unit = Vector.mul(
			m.unit
			Vector.hypotenuse Vector.abs m.unit
		)
	
	# Register four-directional keyboard movement. Specify a player key to
	# associate this movement, as well as a 4-element array of key codes to
	# use for the movement. The key codes represent up, right, down, left
	# respectively. Also, specify a joystick index to assign to this player.
	registerPlayerMovement: (player, keyCodes, stickIndex) ->
		
		# Map the key code and joystick index to the player so we can look 'em up
		# quick when a key code or joystick movement comes in.
		@keyCodeMap[keyCode] = player for keyCode in keyCodes
		@stickIndexMap[stickIndex] = player
		@movement[player] =
			unit: [0, 0]
			keyCodes: keyCodes
			keyState: [0, 0, 0, 0]
			stickIndex: stickIndex
			joyState: [0, 0, 0, 0]

