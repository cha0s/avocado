# SPI proxy and constant definitions.

# **Sprite** handles rendering and transformations. 

Sprite = require('Graphics').Sprite

Sprite::renderTo = (destination) ->
	return unless destination?
	@['%renderTo'] destination
	
Sprite::setAlpha = (alpha = 1) ->
	@['%setAlpha'] alpha

Sprite::setBlendMode = (blendMode) ->
	return unless blendMode?
	@['%setBlendMode'] blendMode

Sprite::setPosition = (position) ->
	return unless position?
	@['%setPosition'] position

Sprite::setRotation = (angle) ->
	return unless angle?
	@['%setRotation'] angle

Sprite::setScale = (factorX, factorY) ->
	return unless factorX? and factorY?
	@['%setScale'] factorX, factorY

Sprite::setSource = (source) ->
	return unless source?
	@['%setSource'] source

Sprite::setSourceRectangle = (rectangle) ->
	return unless rectangle?
	@['%setSourceRectangle'] rectangle
