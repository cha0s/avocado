
PIXI = require 'avo/vendor/pixi'

Renderable = require './renderable'

module.exports = class Text extends Renderable
	
	constructor: (text) ->
		
		@_text = new PIXI.Text text
		
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
		
	internal: -> @_text	
