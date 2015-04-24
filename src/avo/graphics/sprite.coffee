
PIXI = require 'avo/vendor/pixi'

Rectangle = require 'avo/extension/rectangle'

Renderable = require './renderable'

module.exports = class Sprite extends Renderable

  constructor: (@_image) ->
  	super

  	@_sprite = new PIXI.Sprite @_image._texture

  alpha: -> @_sprite.alpha

  image: -> @_image

  setAlpha: (alpha) -> @_sprite.alpha = alpha

  setOrigin: (origin) ->

  	@_sprite.pivot.x = origin[0]
  	@_sprite.pivot.y = origin[1]

  setRotation: (rotation) -> @_sprite.rotation = rotation

  setSourceRectangle: (rectangle) ->

  	@_image._texture.setFrame Rectangle.toObject rectangle

  internal: -> @_sprite
