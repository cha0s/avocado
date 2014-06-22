
PIXI = require 'avo/vendor/pixi'
Rectangle = require 'avo/extension/rectangle'

module.exports = class Sprite
	
	constructor: (@_image) ->
		
		@_sprite = new PIXI.Sprite @_image._texture
	
	addToStage: (stage) -> stage.addChild @_sprite
	
	setPosition: (position) ->
		
		@_sprite.position.x = position[0]
		@_sprite.position.y = position[1]
	
	setSource: (@_image) ->
		
		@_sprite.onTextureUpdate()
	
	setSourceRectangle: (rectangle) ->
		
		@_image._texture.setFrame Rectangle.toObject rectangle
