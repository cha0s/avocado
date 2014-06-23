
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
PIXI = require 'avo/vendor/pixi'
Rectangle = require 'avo/extension/rectangle'
Transition = require 'avo/mixin/transition'

module.exports = class Sprite
	
	mixins = [
		Transition
	]
	
	constructor: (@_image) ->
		mixin.call this for mixin in mixins
		
		@_sprite = new PIXI.Sprite @_image._texture
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	addToStage: (stage) -> stage.addChild @_sprite
	
	alpha: -> @_sprite.alpha
	
	setAlpha: (alpha) -> @_sprite.alpha = alpha
	
	setPosition: (position) ->
		
		@_sprite.position.x = position[0]
		@_sprite.position.y = position[1]
	
	setSource: (@_image) ->
		
		@_sprite.onTextureUpdate()
	
	setSourceRectangle: (rectangle) ->
		
		@_image._texture.setFrame Rectangle.toObject rectangle
