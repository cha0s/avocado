
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
	
	setAlpha: (alpha) -> @_sprite.alpha = alpha
	
	setSourceRectangle: (rectangle) ->
		
		@_image._texture.setFrame Rectangle.toObject rectangle
		
	internal: -> @_sprite
