
PIXI = require 'avo/vendor/pixi'

color = require './color'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

Renderable = require './renderable'

module.exports = class Stage extends Renderable
	
	constructor: -> @_stage = new PIXI.Stage()
	
	addChild: (child) -> @_stage.addChild child.internal()
	
	setBackgroundColor: (backgroundColor) ->
		@_stage.setBackgroundColor backgroundColor.toInteger()
		
	backgroundColor: -> color.fromInteger @_stage.backgroundColor
		
	internal: -> @_stage
