
$ = require 'avo/vendor/jquery'
_ = require 'avo/vendor/underscore'
config = require 'avo/config'
input = require './index'
Vector = require 'avo/extension/vector'

input.Mouse =

  ButtonLeft: 1
  ButtonMiddle: 2
  ButtonRight: 3
  WheelUp: 4
  WheelDown: 5

mousePositionScale = [1, 1]

input.setMousePositionScale = (scale) -> mousePositionScale = scale

calculateMousePositionOnElement = (event, element) ->

  rect = element.getBoundingClientRect()

  Vector.round Vector.mul(
    Vector.sub(
      [event.clientX, event.clientY]
      [rect.left, rect.top]
    )
    mousePositionScale
  )

lastMousePosition = null

emitMouseMove = _.throttle(

  (event, element) ->

    position = calculateMousePositionOnElement event, element

    message =
      position: position

    if lastMousePosition?
      message.delta = Vector.sub position, lastMousePosition

    lastMousePosition = position

    input.emit 'mouseMove', message

  1000 / config.get 'input:mouseMovePerSecond'
)

input.attachMouseListenersTo = (element) ->

  element.addEventListener 'mousemove', (event) ->

    emitMouseMove event, element

  $(element).on 'mouseenter', -> input.emit 'mouseEnter'
  $(element).on 'mouseleave', -> input.emit 'mouseLeave'

  element.addEventListener 'mousedown', (event) ->

    position = calculateMousePositionOnElement event, element

    input.emit(
      'mouseDown'
      position: position
      button: mouseButtonMap event.button
    )

  element.addEventListener 'mouseup', (event) ->

    position = calculateMousePositionOnElement event, element

    input.emit(
      'mouseUp'
      position: position
      button: mouseButtonMap event.button
    )

  element.addEventListener 'mousewheel', (event) ->

    input.emit(
      'mouseWheel'
      delta: if event.wheelDelta > 0 then 1 else -1
    )

mouseButtonMap = (button) ->

  switch button

    when 0 then input.Mouse.ButtonLeft
    when 1 then input.Mouse.ButtonMiddle
    when 2 then input.Mouse.ButtonRight
