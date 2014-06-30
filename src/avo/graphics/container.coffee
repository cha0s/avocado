
PIXI = require 'avo/vendor/pixi'

Renderable = require './renderable'

module.exports = class Container extends Renderable
	
	constructor: ->
		super
		
		@_container = new PIXI.DisplayObjectContainer()
	
	addChild: (child) -> @_container.addChild child.internal()
	
	removeChild: (child) -> @_container.removeChild child.internal()
	
	removeAllChildren: ->
		@_container.removeChild child for child in @_container.children
		
	sortChildren: (fn) -> @_container.children.sort fn
	
	internal: -> @_container
