
config = require 'avo/config'
fs = require 'avo/fs'

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

ui.readUi = (uri) -> fs.readResource "/ui/#{uri}"

ui.loadNode = (uri, canvas, Class = Node) ->

  uriHtml = "#{uri}/index.html"

  ui.readUi(uriHtml).then (html) ->

    ui.addCssRemote "#{
      config.get 'fs:resourcePath'
    }/ui/#{
      uriHtml.replace /.html$/, '.css'
    }"

    node = new Class html

    # Add a class, e.g. /test/thing.html -> test-thing
    nodeClass = uri.substr(1).replace '/', '-'
    node.addClass nodeClass

    # Add the node to the UI container.
    uiContainer = canvas.uiContainer()
    uiContainer.appendChild node.element()

    node
