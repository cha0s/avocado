
FunctionExt = require 'avo/extension/function'

color = require 'avo/graphics/color'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Lfo = require 'avo/mixin/lfo'
Transition = require 'avo/mixin/transition'
VectorMixin = require 'avo/mixin/vector'

module.exports = class Renderable

  mixins = [
    EventEmitter
    Lfo
    Transition
  ]

  constructor: ->
    mixin.call this for mixin in mixins

  FunctionExt.fastApply Mixin, [@::].concat mixins

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

  rotation: -> @internal().rotation
  setRotation: (rotation) -> @internal().rotation = rotation

  opacity: -> @internal().alpha
  setOpacity: (opacity) -> @internal().alpha = opacity

  originX: -> @internal().pivot.x
  setOriginX: (x) -> @internal().pivot.x = x

  originY: -> @internal().pivot.y
  setOriginY: (y) -> @internal().pivot.y = y

  origin: ->
    internal = @internal()

    [internal.pivot.x, internal.pivot.y]

  setOrigin: (origin) ->
    internal = @internal()

    internal.pivot.x = origin[0]
    internal.pivot.y = origin[1]

  scaleX: -> @internal().scale.x
  setScaleX: (x) -> @internal().scale.x = x
  scaleY: -> @internal().scale.y
  setScaleY: (y) -> @internal().scale.y = y

  scale: ->
    internal = @internal()

    [internal.scale.x, internal.scale.y]

  setScale: (scale) ->
    internal = @internal()

    internal.scale.x = scale[0]
    internal.scale.y = scale[1]

  setX: (x) -> @internal().position.x = x

  setY: (y) -> @internal().position.y = y

  setTintRed: (red) ->

    color_ = color.fromInteger @internal().tint
    color_.setRed red
    @internal().tint = color_.toInteger()

  setTintGreen: (green) ->

    color_ = color.fromInteger @internal().tint
    color_.setGreen green
    @internal().tint = color_.toInteger()

  setTintBlue: (blue) ->

    color_ = color.fromInteger @internal().tint
    color_.setBlue blue
    @internal().tint = color_.toInteger()

  setTint: (color) -> @internal().tint = color.toInteger()

  tintRed: ->

    color.fromInteger(@internal().tint).red()

  tintGreen: (green) ->

    color.fromInteger(@internal().tint).green()

  tintBlue: (blue) ->

    color.fromInteger(@internal().tint).blue()

  tint: (color) -> color.fromInteger @internal().tint

  x: -> @internal().position.x

  y: -> @internal().position.y
