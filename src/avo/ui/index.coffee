
config = require 'avo/config'
fs = require 'avo/fs'

UiAbstract = require './abstract'
Node = require './node'

ui = module.exports

ui.addCssText = (text) ->

  css = document.createElement 'style'
  css.type = 'text/css'
  css.innerHTML = text

  window.document.getElementsByTagName('head')[0].appendChild css

ui.addCssRemote = (href) ->

  link = window.document.createElement 'link'
  link.id = href.replace /[^0-9a-zA-Z_]/g, '-'
  link.rel = 'stylesheet'
  link.type = 'text/css'
  link.href = href
  link.media = 'all'

  window.document.getElementsByTagName('head')[0].appendChild link

ui.loadNode = (uri, canvas) ->

  fs.readUi(uri).then (html) ->

    ui.addCssRemote "#{config.get 'fs:uiPath'}#{uri.replace /.html$/, '.css'}"

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
    uiContainer = canvas.uiContainer()
    uiContainer.appendChild node.element()

    node

ui.load = (name, canvas) ->

  try
    Class = require "avo/ui/#{name}"
  catch error
    Class = UiAbstract

  ui.loadNode("/#{name}.html", canvas).then (node) -> new Class node
