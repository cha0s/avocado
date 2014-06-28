
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
PIXI = require 'avo/vendor/pixi'
Rectangle = require 'avo/extension/rectangle'
Transition = require 'avo/mixin/transition'

Renderable = require './renderable'

module.exports = class Sprite extends Renderable
	
	mixins = [
		Transition
	]
	
	constructor: (@_image) ->
		mixin.call this for mixin in mixins
		
		@_sprite = new PIXI.Sprite @_image._texture
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
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
