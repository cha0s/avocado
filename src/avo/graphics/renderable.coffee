
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

module.exports = class Renderable

	mixins = [
		PositionProperty = VectorMixin 'position' 
	]
	
	constructor: (@_stage = new PIXI.Stage()) ->
		mixin.call this for mixin in mixins
		
	FunctionExt.fastApply Mixin, [@::].concat mixins

	internal: -> throw new Error "Renderable::internal is pure virtual"

	setPosition: (position) -> 
		PositionProperty::setPosition.call this, position
	
		internal = @internal()
		
		internal.position.x = position[0]
		internal.position.y = position[1]
