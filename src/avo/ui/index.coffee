
config = require 'avo/config'
fs = require 'avo/fs'
window_ = require 'avo/graphics/window'

UiAbstract = require './abstract'
Node = require './node'

ui = module.exports

ui.addCss = (href) ->

	link = window.document.createElement 'link'
	link.id = href.replace /[^0-9a-zA-Z_]/g, '-'
	link.rel = 'stylesheet'
	link.type = 'text/css'
	link.href = href
	link.media = 'all'

	head = window.document.getElementsByTagName('head')[0]
	head.appendChild link

ui.loadNode = (uri) ->

	fs.readUi(uri).then (html) ->

		ui.addCss "#{config.get 'fs:uiPath'}#{uri.replace /.html$/, '.css'}"

		node = new Node html

		# Set defaults.
		node.hide()
		node.setIsSelectable false
		node.setPosition [0, 0]

		# Add a class, e.g. /test/thing.html -> test-thing
		nodeClass = uri.substr(1).replace '.html', ''
		nodeClass = nodeClass.replace '/', '-'
		node.addClass nodeClass

		# Add the node to the UI container.
		uiContainer = window_.uiContainer()
		uiContainer.appendChild node.element()

		node

ui.load = (name) ->

	try
		Class = require "avo/ui/#{name}"
	catch error
		Class = UiAbstract

	ui.loadNode("/#{name}.html").then (node) -> new Class node
