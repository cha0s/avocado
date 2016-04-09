
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

FunctionExt = require 'avo/extension/function'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

Primitives = require 'avo/graphics/primitives'

module.exports = class Shape

  mixins = [
    VectorMixin(
      'origin', 'originX', 'originY'
      originX: default: 0
      originY: default: 0
    )
    VectorMixin(
      'parentOrigin', 'parentOriginX', 'parentOriginY'
      parentOriginX: default: 0
      parentOriginY: default: 0
    )
    Property 'parentRotation', default: 0
    Property 'parentScale', default: 1
    Property 'rotation', default: 0
    Property 'scale', default: 1
    Property 'type', default: 'index'
    EventEmitter
  ]

  constructor: ->

    mixin.call this for mixin in mixins

    @_primitives = new Primitives()

  FunctionExt.fastApply Mixin, [@::].concat mixins

  aabb: (position) -> [0, 0, 0, 0]

  fromObject: (O) ->

    @setOrigin O.origin if O.origin?
    @setRotation O.rotation if O.rotation?
    @setScale O.scale if O.scale?

    this

  primitives: -> @_primitives

  toJSON: ->

    type: @type()
    origin: @origin()
    rotation: @rotation()
    scale: @scale()
