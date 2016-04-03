
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
          keyMovements[id][axisMap[i]] += velocityMap[i] if code is keyCode

      return

input.registerKeyMovement = (up, right, down, left, id) ->
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

input.registerGamepadAxisMovement = (upDown, leftRight, index, id) ->
  gamepadAxisMovements[id] = [0, 0]
  gamepadAxisMovementMaps[id] = [upDown, leftRight, index]

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

  return

input.registerGamepadButtonMovement = (up, right, down, left, index, id) ->
  gamepadButtonMovements[id] = [0, 0]
  gamepadButtonMovementMaps[id] = [up, right, down, left, index]

# Simplified helper for registering default movement.
input.registerMovement = ->

  input.registerKeyMovement()
  input.registerGamepadAxisMovement()
  input.registerGamepadButtonMovement()

input.unitMovement = (id = 0) ->
  movement = [0, 0]
  movement = Vector.add movement, keyMovements[id] if keyMovements[id]?

  if gamepadAxisMovements[id]?
    movement = Vector.add movement, gamepadAxisMovements[id]

  if gamepadButtonMovements[id]?
    movement = Vector.add movement, gamepadButtonMovements[id]

  Vector.min Vector.max(movement, [-1, -1]), [1, 1]
