# SPI proxy and constant definitions.

# **Window** handles window creation and properties of the window. 

Graphics = require 'Graphics'
Timing = require 'Timing'

EventEmitter = require '../Mixin/EventEmitter'
FunctionExt = require '../Extension/Function'
Mixin = require '../Mixin/Mixin'
Property = require '../Mixin/Property'
Vector = require '../Extension/Vector'

Window = Graphics.Window

WindowMixin = class
	
	constructor: ->
		
		for inputEvent in [
			'keyDown', 'keyUp'
			'joyAxis', 'joyButtonDown', 'joyButtonUp'
			'mouseButtonDown', 'mouseButtonUp', 'mouseDrag', 'mouseMove', 'mouseWheelMove'
			'resize'
			'quit'
		]
			
			do (inputEvent) =>
				@on(
					inputEvent
					=>
						
						return unless (inputReceiver = @inputReceiver())?
						return unless inputReceiver.emit?
						
						args = ['inputEvent', inputEvent]
						args.push argument for argument in arguments
						
						FunctionExt.fastApply(
							inputReceiver.emit, args, inputReceiver
						)
				)
		
		# We want to store how much a player is moving either with the
		# arrow keys or the joystick/gamepad.
		@_movement = {}
		@_keyCodeMap = {}
		@_stickIndexMap = {}
		
		# Joystick movement.
		@on 'joyAxis.Avocado', ({stickIndex, axis, value}) =>
		
			axisMap = 0: 0, 1: 1, 6: 0, 7: 1
			return unless (axis = axisMap[axis])?
				
			return unless (player = @_stickIndexMap[stickIndex])?
			return unless m = @_movement[player]
			
			if value > .3
				m.joyState[if axis is 0 then 1 else 2] = Math.abs value
			else if value < -.3
				m.joyState[if axis is 0 then 3 else 0] = Math.abs value
			else
				if axis is 0
					m.joyState[1] = m.joyState[3] = 0
				else
					m.joyState[0] = m.joyState[2] = 0
			
			@registerMovement player
			
		# Keyboard movement started.
		@on 'keyDown.Avocado', ({code}) =>
			
			return unless (player = @_keyCodeMap[code])?
			return unless m = @_movement[player]
			
			m.keyState[m.keyCodes.indexOf code] = 1
			
			@registerMovement player
			
		# Keyboard movement stopped.
		@on 'keyUp.Avocado', ({code}) =>
		
			return unless (player = @_keyCodeMap[code])?
			return unless m = @_movement[player]
		
			m.keyState[m.keyCodes.indexOf code] = 0
			
			@registerMovement player
		
		# Mouse dragging is a bit of a higher-level concept. We'll
		# implement it using the low-level API.
		@_buttons = {}
		@_dragStartLocation = {}
		@_mouseLocation = [0, 0]
		
		Mouse = Graphics.Window.Mouse
		
		# Start dragging when a button is clicked.
		@on 'mouseButtonDown.Avocado', ({button}) =>
			switch button
				when Mouse.ButtonLeft, Mouse.ButtonMiddle, Mouse.ButtonRight
					@_dragStartLocation[button] = @_mouseLocation
					@_buttons[button] = true
				
		# Stop dragging when a button is released.
		@on 'mouseButtonUp.Avocado', ({button}) =>
			switch button
				when Mouse.ButtonLeft, Mouse.ButtonMiddle, Mouse.ButtonRight
					delete @_buttons[button]
					delete @_dragStartLocation[button]
		
		# When the mouse moves,
		@on 'mouseMove.Avocado', ({x, y}) =>
			@_mouseLocation = [x, y]
			
			# Check if any buttons are being held down
			keys = Object.keys @_buttons
			if keys.length > 0
				
				# If so, send a mouseDrag event for each of them.
				for key in keys
					@emit(
						'mouseDrag'
							position: @_mouseLocation
							button: parseInt key
							relative: Vector.sub(
								@_mouseLocation
								@_dragStartLocation[key]
							)
					)

	# Get a unit movement vector for a player.
	playerTickMovement: (player) ->
		
		return [0, 0] unless @_movement[player]?
		
		@_movement[player].unit
	
	# Poll for events sent to this window.
	pollEvents: ->
		
		@['%pollEvents']()
		
		return unless (inputReceiver = @inputReceiver())?
		return unless inputReceiver.emit?
		
		for player of @_movement
		
			inputReceiver.emit(
				'inputEvent'
				'unitMovement'
				player: player
				movement: @playerTickMovement player
			)
	
	# We'll store any movement that comes in, combining keyboard and
	# joystick movement, making sure that combined they never exceed 1.
	registerMovement: (player) ->
		
		m = @_movement[player]
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
		@_keyCodeMap[keyCode] = player for keyCode in keyCodes
		@_stickIndexMap[stickIndex] = player
		@_movement[player] =
			unit: [0, 0]
			keyCodes: keyCodes
			keyState: [0, 0, 0, 0]
			stickIndex: stickIndex
			joyState: [0, 0, 0, 0]

mixins = [
	EventEmitter
	Property 'inputReceiver', null
	WindowMixin
]

FunctionExt.fastApply Mixin, [Window::].concat mixins

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

	mixin.call _window for mixin in mixins
	
	_window.setSize size if size?
	_window.setFlags flags if flags?
	
	_window

# Show the window.
Window::display = -> @['%display']()

# The height of the window.
Window::height = -> @size()[1]

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
