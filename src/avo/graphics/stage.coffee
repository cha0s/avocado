
PIXI = require 'avo/vendor/pixi'

color = require './color'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

Renderable = require './renderable'

module.exports = class Stage

  constructor: ->

  	@_stage = new PIXI.Stage()
  	@_stage.interactive = false

  addChild: (child) -> @_stage.addChild child.internal()

  removeChild: (child) -> @_stage.removeChild child.internal()

  removeAllChildren: ->
  	@_stage.removeChild child for child in @_stage.children

  setBackgroundColor: (backgroundColor) ->
  	@_stage.setBackgroundColor backgroundColor.toInteger()

  backgroundColor: -> color.fromInteger @_stage.backgroundColor

  internal: -> @_stage
