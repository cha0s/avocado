
Promise = require 'vendor/bluebird'
TextStyle = require 'avo/graphics/textStyle'
Vector = require 'avo/extension/vector'

config = require 'avo/config'

module.exports = class Font

  constructor: ->

    @_family = ''

  @textNode: (text, textStyle) ->

    node = window.document.createElement 'span'
    node.innerHTML = text
    # Visible - so we can measure it - but not on the screen
    node.style.position      = 'absolute'
    node.style.left          = '-10000px'
    node.style.top           = '-10000px'

    node.style.font = textStyle.fontString()

    node

  family: -> @_family

  textStyle = new TextStyle fontSize: 300

  # Adapted from http://stackoverflow.com/a/11689060
  pollForLoadedFont = (font) ->

    new Promise (resolve, reject) ->

      window.document.body.appendChild node = Font.textNode(
        # Characters that vary significantly among different fonts
        'giItT1WQy@!-/#', textStyle
      )

      width = node.offsetWidth

      node.style.fontFamily = font._family

      checkFont = ->

        if node and node.offsetWidth isnt width

          node.parentNode.removeChild node
          node = null

          clearInterval interval
          resolve font

      interval = setInterval checkFont, 5

  Fonts = {}
  @load: (uri) ->

    return Fonts[uri] if Fonts[uri]?

    deferred = Promise.defer()
    Fonts[uri] = deferred.promise

    font = new Font()
    font._family = uri.replace /[^A-Za-z0-9_\-]/g, ''

    fontStyle = window.document.createElement 'style'
    fontStyle.appendChild window.document.createTextNode """
@font-face {
  font-family: "#{font._family}";
  src: url("#{config.get 'fs:resourcePath'}#{uri}") format("truetype");
}
"""
    window.document.getElementsByTagName('head').item(0).appendChild fontStyle

    Fonts[uri] = pollForLoadedFont font
