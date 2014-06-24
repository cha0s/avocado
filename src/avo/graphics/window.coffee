
PIXI = require 'avo/vendor/pixi'
Vector = require 'avo/extension/vector'

config = require 'avo/config'
Renderer = require 'avo/graphics/renderer'

instantiated = false
offset = []
renderer = null

exports.close = ->
	
	if 'node-webkit' is config.get 'platform'
		
		{Window} = global.window.nwDispatcher.requireNwGui()
		window_ = Window.get()
		
		window_.close()

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
	
	rendererSize = renderer.size()
	
	ratios = [
		rendererSize[0] / rendererSize[1]
		rendererSize[1] / rendererSize[0]
	]
	
	centerCanvas = ->
		
		height = window.innerHeight
		width = window.innerWidth
		
		calculatedHeight = height
		calculatedWidth = height * ratios[0]
		
		if calculatedWidth > width
			calculatedWidth = width
			calculatedHeight = width * ratios[1]
			
		offset = [
			(width - calculatedWidth) / 2
			(height - calculatedHeight) / 2
		]
		
		container.style.width = "#{calculatedWidth}px"
		container.style.height = "#{calculatedHeight}px"
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
