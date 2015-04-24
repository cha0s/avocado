
PIXI = require 'avo/vendor/pixi'

Renderable = require './renderable'

module.exports = class Container extends Renderable

	constructor: ->
		super

		@_container = new PIXI.DisplayObjectContainer()

	addChild: (child) -> @_container.addChild child.internal()

	children: -> @_container.children

	removeChild: (child) -> @_container.removeChild child.internal()

	removeAllChildren: ->

		while @_container.children.length > 0
			@_container.removeChildAt @_container.children.length - 1

	sortChildren: (fn) -> @_container.children.sort fn

	internal: -> @_container
