# SPI proxy and constant definitions.

# **Sprite** handles rendering and transformations. 

exports.proxy = ({Sprite}) ->

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
	
	Sprite::setRotation = (angle, orientation = [0, 0]) ->
		return unless angle?
		@['%setRotation'] angle, orientation
	
	Sprite::setScale = ([factorX, factorY]) ->
		return unless factorX? and factorY?
		@['%setScale'] factorX, factorY
	
	Sprite::setSource = (source) ->
		return unless source?
		@['%setSource'] source
	
	Sprite::setSourceRectangle = (rectangle) ->
		return unless rectangle?
		@['%setSourceRectangle'] rectangle
