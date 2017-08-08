
PIXI = require 'vendor/pixi'

Renderable = require 'avo/graphics/renderable'

module.exports = class Container extends Renderable

  constructor: ->
    super

    @_container = new PIXI.Container()

  addChildAt: (child, index) -> @_container.addChildAt child.internal(), index
  addChild: (child) -> @_container.addChild child.internal()

  children: -> @_container.children

  removeChild: (child) -> @_container.removeChild child.internal()

  removeAllChildren: -> @_container.removeChildren()

  sortChildren: (fn) -> @_container.children.sort fn

  internal: -> @_container
