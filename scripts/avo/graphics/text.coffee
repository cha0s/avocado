
PIXI = require 'avo/vendor/pixi'

module.exports = class Text
	
	constructor: (text) ->
		
		@_text = new PIXI.Text text
		
	addToStage: (stage) ->
		
		stage.addChild @_text
	
	setColor: (color) ->
		
		@_text.style.fill = color.toCss()
		@_text.style.stroke = color.toCss()
		@_text.dirty = true
	
	setFillColor: (color) ->
		
		@_text.style.fill = color.toCss()
		@_text.dirty = true
	
	setFont: (font, style = '12px') ->
		
		@_text.style.font = "#{style} #{font._family}"
		@_text.dirty = true
		
	setPosition: (position) ->
		
		@_text.position.x = position[0]
		@_text.position.y = position[1]
		
	setStrokeColor: (color) ->
		
		@_text.style.stroke = color.toCss()
		@_text.dirty = true
	
	setStrokeThickness: (px) ->
		
		@_text.style.strokeThickness = px
		@_text.dirty = true
	
	setText: (text) ->
		
		oldText = @_text.text
		return if oldText is text
		
		@_text.setText text	
