
PIXI = require 'avo/vendor/pixi'
Promise = require 'avo/vendor/bluebird'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

config = require 'avo/config'

# Why AvoImage and not Image, you may ask? Because (window.)Image is already
# present in a browser environment, and it's better for us to leave it alone.

module.exports = class AvoImage

  constructor: ([width, height] = [0, 0]) ->

    @_uri = ''

    # canvas = window.document.createElement 'canvas'
    # console.log width, height
    # canvas.width = 1
    # canvas.height = 1
    # canvas.width = width
    # canvas.height = height


    image = new window.Image()
    image.width = width
    image.height = height
    baseTexture = new PIXI.BaseTexture image
    baseTexture.width = width
    baseTexture.height = height
    @_texture = new PIXI.Texture baseTexture

  @fromTexture: (texture) ->

    image = new AvoImage()

    image._texture = texture

    image

  @load: (uri, fn) ->

    new Promise (resolve, reject) ->

      texture = PIXI.Texture.fromImage "#{
        config.get 'fs:resourcePath'
      }#{
        uri
      }"

      onloadProxy = texture.baseTexture.source.onload
      texture.baseTexture.source.onload = ->
        onloadProxy?()

        image = new AvoImage()

        image._uri = uri
        image._texture = texture

        resolve image

      onerrorProxy = texture.baseTexture.source.onerror
      texture.baseTexture.source.onerror = ->
        onerrorProxy?()

        reject new Error "Couldn't load Image: #{uri}"

  @loadWithoutCache: (uri, fn) ->

    new Promise (resolve, reject) ->

      texture = new PIXI.Texture PIXI.BaseTexture.fromImage "#{
        config.get 'fs:resourcePath'
      }#{
        uri
      }"

      onloadProxy = texture.baseTexture.source.onload
      texture.baseTexture.source.onload = ->
        onloadProxy?()

        image = new AvoImage()

        image._uri = uri
        image._texture = texture

        resolve image

      onerrorProxy = texture.baseTexture.source.onerror
      texture.baseTexture.source.onerror = ->
        onerrorProxy?()

        reject new Error "Couldn't load Image: #{uri}"

  height: -> @_texture.baseTexture.height

  size: -> [@width(), @height()]

  uri: -> @_uri

  width: -> @_texture.baseTexture.width
