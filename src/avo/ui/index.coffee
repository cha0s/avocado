
config = require 'avo/config'
fs = require 'avo/fs'
Node = require './node'
window_ = require 'avo/graphics/window'

ui = module.exports

ui.load = (uri) ->
	
	fs.readUi(uri).then (html) ->
		
		uiContainer = window_.uiContainer()
		
		cssHref = "#{config.get 'fs:uiPath'}#{uri.replace /.html$/, '.css'}"
		cssId = cssHref.replace /[^0-9a-zA-Z_]/g, '-'
		
		link = window.document.createElement 'link'
		link.id = cssId
		link.rel = 'stylesheet'
		link.type = 'text/css'
		link.href = cssHref
		link.media = 'all'
	
		head = window.document.getElementsByTagName('head')[0]
		head.appendChild link
		
		node = new Node html
		
		node.setPosition [0, 0]
	
		node.hide()
		node.setIsSelectable false
		
		node
