
Vector = require 'avo/extension/vector'

input = require './index'

keyMovements = {}
keyMovementMaps = {}

for keyEvent in ['keyDown', 'keyUp']

	do (keyEvent) ->

		axisMap = [1, 0, 1, 0]
		velocityMap = [-1, 1, 1, -1]

		# Reverse for keyUp.
		velocityMap = (-value for value in velocityMap) if 'keyUp' is keyEvent

		input.on keyEvent, ({keyCode, repeat}) ->
			return if repeat

			for id, keyMovementMap of keyMovementMaps
				for code, i in keyMovementMap
					if code is keyCode
						keyMovements[id][axisMap[i]] += velocityMap[i]

input.registerKeyMovement = (
	up = input.Key.W
	right = input.Key.D
	down = input.Key.S
	left = input.Key.A
	id = 0
) ->

	keyMovements[id] = [0, 0]
	keyMovementMaps[id] = [up, right, down, left]

gamepadAxisMovements = {}
gamepadAxisMovementMaps = {}

input.on 'gamepadAxis', ({index, axis, state}) ->

	for id, [upDownAxis, leftRightAxis, mapIndex] of gamepadAxisMovementMaps
		continue unless mapIndex is index

		if axis is upDownAxis
			gamepadAxisMovements[id][1] = state

		else if axis is leftRightAxis
			gamepadAxisMovements[id][0] = state

input.registerGamepadAxisMovement = (
	upDownAxis = 1
	leftRightAxis = 0
	index = 0
	id = 0
) ->

	gamepadAxisMovements[id] = [0, 0]
	gamepadAxisMovementMaps[id] = [upDownAxis, leftRightAxis, index]

gamepadButtonMovements = {}
gamepadButtonMovementMaps = {}

input.on 'gamepadButton', ({index, button, state}) ->

	axisMap = [1, 0, 1, 0]
	velocityMap = [-1, 1, 1, -1]

	# Reverse for button release.
	velocityMap = (-value for value in velocityMap) if 0 is state

	for id, gamepadButtonMovementMap of gamepadButtonMovementMaps
		continue unless gamepadButtonMovementMap[4] is index

		for i in [0...4]
			if button is gamepadButtonMovementMap[i]
				gamepadButtonMovements[id][axisMap[i]] += velocityMap[i]

input.registerGamepadButtonMovement = (
	upButton = 12
	rightButton = 15
	downButton = 13
	leftButton = 14
	index = 0
	id = 0
) ->

	gamepadButtonMovements[id] = [0, 0]
	gamepadButtonMovementMaps[id] = [upButton, rightButton, downButton, leftButton, index]

# Simplified helper for registering default movement.
input.registerMovement = ->

	input.registerKeyMovement()
	input.registerGamepadAxisMovement()
	input.registerGamepadButtonMovement()

input.unitMovement = (id = 0) ->

	movement = [0, 0]

	if keyMovements[id]?
		movement = Vector.add movement, keyMovements[id]

	if gamepadAxisMovements[id]?
		movement = Vector.add movement, gamepadAxisMovements[id]

	if gamepadButtonMovements[id]?
		movement = Vector.add movement, gamepadButtonMovements[id]

	Vector.min Vector.max(movement, [-1, -1]), [1, 1]
