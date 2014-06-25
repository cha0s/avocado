
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

module.exports = class Renderable

	constructor: (@_stage = new PIXI.Stage()) ->
		
	internal: -> throw new Error "Renderable::internal is pure virtual"
	
	isVisible: -> @internal().visible
	
	localRectangle: ->
		
		bounds = @internal().getLocalBounds()
		[bounds.x, bounds.y, bounds.width, bounds.height]
	
	position: -> 
	
		internal = @internal()
		[internal.position.x, internal.position.y]

	rectangle: ->
		
		bounds = @internal().getBounds()
		[bounds.x, bounds.y, bounds.width, bounds.height]
	
	setPosition: (position) -> 
	
		internal = @internal()
		
		internal.position.x = position[0]
		internal.position.y = position[1]
		
	setIsVisible: (isVisible) -> @internal().visible = isVisible

	setX: (x) -> @internal().position.x = x
	
	setY: (y) -> @internal().position.y = y
		
	x: -> @internal().position.x
	
	y: -> @internal().position.y
	