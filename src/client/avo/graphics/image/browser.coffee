
PIXI = require 'vendor/pixi'
Promise = require 'vendor/bluebird'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

config = require 'avo/config'

# Why AvoImage and not Image, you may ask? Because (window.)Image is already
# present in a browser environment, and it's better for us to leave it alone.

browserImageCache = {}

module.exports = class AvoImage

  constructor: ([width, height] = [0, 0]) ->

    @_uri = ''

    image = new window.Image()
    [image.width, image.height] = [width, height]

    baseTexture = new PIXI.BaseTexture image
    [baseTexture.width, baseTexture.height] = [width, height]

    @_texture = new PIXI.Texture baseTexture

  @fromTexture: (texture) ->

    image = new AvoImage()

    image._texture = texture

    image

  @loadBrowserImage: (uri) ->

    return browserImageCache[uri] if browserImageCache[uri]?

    browserImageCache[uri] = new Promise (resolve, reject) ->

      image = new window.Image()

      image.onload = -> resolve image

      image.onerror = (error) ->

        reject new Error "Couldn't load Image: #{
          uri
        }, reason: #{
          error.message
        }"

      image.src = "#{
        config.get 'fs:resourcePath'
      }#{
        uri
      }"

  @load: (uri) ->

    @loadBrowserImage(uri).then (browserImage) ->

      texture = new PIXI.Texture new PIXI.BaseTexture browserImage

      image = new AvoImage()

      image._uri = uri
      image._texture = texture

      return image

  clone: ->

    texture = new PIXI.Texture new PIXI.BaseTexture @_texture.baseTexture.source
    clone = new AvoImage()
    clone._uri = @_uri
    clone._texture = texture

    return clone

  height: -> @_texture.baseTexture.height

  size: -> [@width(), @height()]

  uri: -> @_uri

  width: -> @_texture.baseTexture.width
