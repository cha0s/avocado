
_ = require 'avo/vendor/underscore'
Vector = require 'avo/extension/vector'

exports.attachListeners = (input, config) ->

  lastPosition = null

  mouseMovesPerSecond = config.mouseMovesPerSecond ? 50

  emitMouseMove = (event) ->
    position = [event.clientX, event.clientY]

    message = position: position
    message.delta = Vector.sub position, lastPosition if lastPosition?

    lastPosition = position

    input.emit 'mouseMove', message, event

  if mouseMovesPerSecond > 0
    emitMouseMove = _.throttle emitMouseMove, mouseMovesPerSecond

  window.addEventListener 'mousemove', (event) ->
    event ?= window.event

    emitMouseMove event

  window.addEventListener 'mousedown', (event) ->
    event ?= window.event

    input.emit(
      'mouseDown'
      position: [event.clientX, event.clientY]
      button: event.button
      event
    )

  window.addEventListener 'mouseup', (event) ->
    event ?= window.event

    input.emit(
      'mouseUp'
      position: [event.clientX, event.clientY]
      button: event.button
      event
    )

  window.addEventListener 'mousewheel', (event) ->
    event ?= window.event

    input.emit(
      'mouseWheel'
      delta: if event.wheelDelta > 0 then 1 else -1
      event: event
    )

  input.MouseButton =

    Left: 1
    Middle: 2
    Right: 3
