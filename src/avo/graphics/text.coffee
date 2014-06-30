
PIXI = require 'avo/vendor/pixi'

FunctionExt = require 'avo/extension/function'

Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

Font = require './font'
Renderable = require './renderable'

module.exports = class Text extends Renderable
	
	mixins = [
		Property 'fontFamily', 'sans-serif'
		Property 'fontSize', 12
	]
	
	constructor: (text) ->
		super
		
		mixin.call this for mixin in mixins
		
		@_text = new PIXI.Text text
		
		@on [
			'fontFamilyChanged', 'fontSizeChanged'
		], =>
			
			@_text.style.font = "#{@fontSize()}px #{@fontFamily()}"
			@_text.dirty = true

		@_text.style.font = "#{@fontSize()}px #{@fontFamily()}"
		@_text.dirty = true
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
		
	setColor: (color) ->
		
		@_text.style.fill = color.toCss()
		@_text.style.stroke = color.toCss()
		@_text.dirty = true
	
	setFillColor: (color) ->
		
		@_text.style.fill = color.toCss()
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
		
	textSize: ->
		
		node = Font.textNode @_text.text, @_text.style.font
		window.document.body.appendChild node
		size = [node.clientWidth, node.clientHeight]
		window.document.body.removeChild node
		return size
		
	internal: -> @_text	
