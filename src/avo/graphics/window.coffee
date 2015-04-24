
PIXI = require 'avo/vendor/pixi'
Vector = require 'avo/extension/vector'

config = require 'avo/config'
input = require 'avo/input'
Node = require 'avo/ui/node'
Renderer = require 'avo/graphics/renderer'

container = null
instantiated = false
offset = []
renderer = null
uiContainer = null

exports.close = ->

  if 'node-webkit' is config.get 'platform'

  	{Window} = global.window.nwDispatcher.requireNwGui()
  	window_ = Window.get()

  	window_.close()

exports.container = -> container

exports.hide = ->

  if 'node-webkit' is config.get 'platform'

  	{Window} = global.window.nwDispatcher.requireNwGui()
  	window_ = Window.get()

  	window_.hide()

exports.instantiate = ->
  return if instantiated
  instantiated = true

  renderer = new Renderer(
  	config.get 'graphics:resolution'
  	config.get 'graphics:renderer'
  )

  container = window.document.createElement 'div'
  container.style.position = 'absolute'
  container.style.overflow = 'hidden'
  container.appendChild renderer.element()
  window.document.body.appendChild container

  input.attachMouseListenersTo container

  uiContainer = window.document.createElement 'div'
  uiContainer.style.position = 'absolute'
  uiContainer.style.left = '0px'
  uiContainer.style.top = '0px'

  container.appendChild uiContainer

  uiContainerNode = new Node uiContainer

  rendererSize = renderer.size()

  ratios = [
  	rendererSize[0] / rendererSize[1]
  	rendererSize[1] / rendererSize[0]
  ]

  centerCanvas = ->

  	windowSize = [
  		window.innerWidth
  		window.innerHeight
  	]

  	calculatedSize = [
  		windowSize[1] * ratios[0]
  		windowSize[1]
  	]

  	if calculatedSize[0] > windowSize[0]
  		calculatedSize = [
  			windowSize[0]
  			windowSize[0] * ratios[1]
  		]

  	calculatedSize = Vector.round calculatedSize
  	container.style.width = "#{calculatedSize[0]}px"
  	container.style.height = "#{calculatedSize[1]}px"

  	uiContainerNode.setScale Vector.div calculatedSize, renderer.size()

  	containerReverseScale = Vector.div renderer.size(), calculatedSize
  	input.setMousePositionScale containerReverseScale

  	containerSize = Vector.scale containerReverseScale, 100
  	uiContainer.style.width = "#{containerSize[0]}%"
  	uiContainer.style.height = "#{containerSize[1]}%"

  	offset = Vector.scale Vector.sub(windowSize, calculatedSize), .5
  	container.style.left = "#{offset[0]}px"
  	container.style.top = "#{offset[1]}px"

  do window.onresize = centerCanvas

  return

exports.offset = -> Vector.copy offset

exports.renderer = -> renderer

exports.show = ->

  if 'node-webkit' is config.get 'platform'

  	{Window} = global.window.nwDispatcher.requireNwGui()
  	window_ = Window.get()

  	window_.show()

exports.size = -> renderer.size()

exports.uiContainer = -> uiContainer
