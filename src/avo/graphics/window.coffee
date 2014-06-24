
PIXI = require 'avo/vendor/pixi'
Vector = require 'avo/extension/vector'

config = require 'avo/config'

instantiated = false
offset = []
renderer = null

exports.close = ->
	
	if 'node-webkit' config.get 'platform'
		
		{Window} = global.window.nwDispatcher.requireNwGui()
		window_ = Window.get()
		
		window_.close()

exports.hide = ->

	if 'node-webkit' config.get 'platform'
		
		{Window} = global.window.nwDispatcher.requireNwGui()
		window_ = Window.get()

		window_.hide()

exports.instantiate = ->
	return if instantiated
	instantiated = true
	
	resolution = config.get 'graphics:resolution'
	
	renderer = switch config.get 'graphics:renderer'
		
		when 'auto'
			PIXI.autoDetectRenderer resolution[0], resolution[1]
			
		when 'canvas'
			new PIXI.CanvasRenderer resolution[0], resolution[1]

		when 'webgl'
			new PIXI.WebGLRenderer resolution[0], resolution[1]
	
	container = window.document.createElement 'div'
	container.style.position = 'absolute'
	container.style.overflow = 'hidden'
	container.appendChild renderer.view
	
	window.document.body.appendChild container
	
	ratios = [
		renderer.view.width / renderer.view.height
		renderer.view.height / renderer.view.width
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

	if 'node-webkit' config.get 'platform'
		
		{Window} = global.window.nwDispatcher.requireNwGui()
		window_ = Window.get()

		window_.show()

exports.size = -> [renderer.view.width, renderer.view.height]