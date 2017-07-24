
color = require 'avo/graphics/color'
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Lfo = require 'avo/mixin/lfo'
Property = require 'avo/mixin/property'
StringExt = require 'avo/extension/string'
Transition = require 'avo/mixin/transition'
Vector = require 'avo/extension/vector'
VectorMixin = require 'avo/mixin/vector'

module.exports = class Renderable

  mixins = [
    EventEmitter
    Lfo
    Transition

    Property(
      'isVisible'
      get: -> @internal().visible
      set: (isVisible) -> @internal().visible = isVisible
    )

    Property(
      'opacity'
      get: -> @internal().alpha
      set: (opacity) -> @internal().alpha = opacity
    )

    Property(
      'rotation'
      get: -> @internal().rotation
      set: (rotation) -> @internal().rotation = rotation
    )

    VectorMixin(
      'origin', 'originX', 'originY'
      originX:
        get: -> @internal().pivot.x
        set: (x) -> @internal().pivot.x = x
      originY:
        get: -> @internal().pivot.y
        set: (y) -> @internal().pivot.y = y
    )

    VectorMixin(
      'position', 'x', 'y'
      x:
        get: -> @internal().x
        set: (x) -> @internal().x = x
      y:
        get: -> @internal().y
        set: (y) -> @internal().y = y
    )

    VectorMixin(
      'scale', 'scaleX', 'scaleY'
      scaleX:
        get: -> @internal().scale.x
        set: (x) -> @internal().scale.x = x
      scaleY:
        get: -> @internal().scale.y
        set: (y) -> @internal().scale.y = y
    )

    Property(
      'tint'
      get: -> color.fromInteger @internal().tint
      set: (color) -> @internal().tint = color.toInteger()
    )
  ]

  for componentName in ['red', 'green', 'blue']
    capitalizedName = StringExt.capitalize componentName

    do (componentName, capitalizedName) -> mixins.push Property(
      "tint#{capitalizedName}"
      get: -> color.fromInteger(@internal().tint)[componentName]()
      set: (component) ->

        color_ = color.fromInteger @internal().tint
        color_["set#{capitalizedName}"] component
        @internal().tint = color_.toInteger()
    )

  constructor: -> mixin.call this for mixin in mixins

  FunctionExt.fastApply Mixin, [@::].concat mixins

  internal: -> throw new Error "Renderable::internal is pure virtual"

  localRectangle: ->

    bounds = @internal().getLocalBounds()
    [bounds.x, bounds.y, bounds.width, bounds.height]

  rectangle: ->

    bounds = @internal().getBounds()
    [bounds.x, bounds.y, bounds.width, bounds.height]
