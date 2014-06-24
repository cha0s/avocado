
PIXI = require 'avo/vendor/pixi'

color = require './color'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

Renderable = require './renderable'

module.exports = class Container extends Renderable
	
	constructor: -> @_container = new PIXI.DisplayObjectContainer()
	
	addChild: (child) -> @_container.addChild child.internal()
	
	internal: -> @_container
