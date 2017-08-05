
dispatch = (type, event, target, positions) ->
  vmouseevent = new Event type, bubbles: event.bubbles
  vmouseevent.parentEvent = event

  for position in ['client', 'offset', 'page', 'radius', 'screen']
    for axe in ['X', 'Y']
      key = "#{position}#{axe}"
      vmouseevent[key] = positions[key]

  for key in ['isClick', 'isTouch']
    vmouseevent[key] = positions[key]

  propagationStopped = false
  stopPropagation = vmouseevent.stopPropagation
  vmouseevent.stopPropagation = ->
    propagationStopped = true
    stopPropagation.call event

  result = event.target.dispatchEvent vmouseevent

  event.stopPropagation() if propagationStopped

  return result

mouseEventHandlers = {}

mouseevent = (type) -> (event) ->

    event.isClick = true
    event.isTouch = false

    event.radiusX = event.radiusY = 0

    dispatch type, event, event.target, event

mouseEventHandlers.mousedown = mouseevent 'vmousedown'
mouseEventHandlers.mousemove = mouseevent 'vmousemove'
mouseEventHandlers.mouseup = mouseevent 'vmouseup'

touchevent = (type) -> (event) ->
  return unless event.changedTouches.length > 0
  touch = event.changedTouches[0]

  # Emulate offset for touch events.
  rect = event.target.getBoundingClientRect()
  touch.offsetX = touch.clientX - rect.left
  touch.offsetY = touch.clientY - rect.top

  touch.isClick = false
  touch.isTouch = true

  return dispatch type, event, touch.target, touch

mouseEventHandlers.touchstart = touchevent 'vmousedown'
mouseEventHandlers.touchmove = touchevent 'vmousemove'
mouseEventHandlers.touchend = touchevent 'vmouseup'

exports.attachVirtualMouseEvents = (node, emulateMouseOnMobile = false) ->
  for type, handler of mouseEventHandlers
    node.addEventListener type, handler, false

exports.removeVirtualMouseEvents = (node) ->
  for type, handler of mouseEventHandlers
    node.removeEventListener type, handler, false
