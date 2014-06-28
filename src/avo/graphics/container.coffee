
PIXI = require 'avo/vendor/pixi'

color = require './color'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

Renderable = require './renderable'

module.exports = class Container extends Renderable
	
	constructor: -> @_container = new PIXI.DisplayObjectContainer()
	
	addChild: (child) -> @_container.addChild child.internal()
	
	removeChild: (child) -> @_container.removeChild child.internal()
	
	removeAllChildren: ->
		@_container.removeChild child for child in @_container.children
		
	sortChildren: (fn) -> @_container.children.sort fn
	
	internal: -> @_container
