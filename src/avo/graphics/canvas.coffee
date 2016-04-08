
uuid = require 'avo/vendor/uuid'

Vector = require 'avo/extension/vector'

EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

input = require 'avo/input'
Node = require 'avo/ui/node'
Renderer = require 'avo/graphics/renderer'

canvases = {}

module.exports = class AvoCanvas

  mixins = [
    EventEmitter
  ]

  @element: (uuid) -> canvases[uuid]

  constructor: (resolution, renderer) ->
    mixin.call this for mixin in mixins

    @_renderer = new Renderer resolution, renderer

    @_calculatedSize = [0, 0]

    @_container = window.document.createElement 'div'
    @_container.style.position = 'absolute'
    @_container.style.overflow = 'hidden'
    @_container.appendChild @_renderer.element()
    window.document.body.appendChild @_container

    # TODO multi
    # input.attachMouseListenersTo @_container

    uiContainer = window.document.createElement 'div'
    uiContainer.style.position = 'absolute'
    uiContainer.style.left = '0px'
    uiContainer.style.top = '0px'

    @_container.appendChild uiContainer

    @_uiContainerNode = new Node uiContainer

    @_renderer.element().dataset.uuid = @_uuid = uuid.v4()
    canvases[@_uuid] = this

  scale: -> Vector.div @_renderer.size(), @_calculatedSize

  renderer: -> @_renderer

  resize: (containerSize) ->

    @_calculatedSize = [
      containerSize[1] * @_renderer.width() / @_renderer.height()
      containerSize[1]
    ]

    @_calculatedSize = [
      containerSize[0]
      containerSize[0] * @_renderer.height() / @_renderer.width()
    ] if @_calculatedSize[0] > containerSize[0]

    @_calculatedSize = Vector.round @_calculatedSize
    @_container.style.width = "#{@_calculatedSize[0]}px"
    @_container.style.height = "#{@_calculatedSize[1]}px"

    @_uiContainerNode.setScale Vector.div @_calculatedSize, @_renderer.size()

    uiContainerSize = Vector.scale @scale(), 100
    uiContainer = @_uiContainerNode.element()
    uiContainer.style.width = "#{uiContainerSize[0]}%"
    uiContainer.style.height = "#{uiContainerSize[1]}%"

    offset = Vector.scale Vector.sub(containerSize, @_calculatedSize), .5
    @_container.style.left = "#{offset[0]}px"
    @_container.style.top = "#{offset[1]}px"

  size: -> @_renderer.size()

  uiContainer: -> @_uiContainerNode.element()

  unlink: ->
    return unless canvases[@_uuid]?

    elm.parent.removeChild elm for elm in [
      @_container, @_renderer.element(), @_uiContainerNode.element()
    ]

    delete canvases[@_uuid]

  FunctionExt.fastApply Mixin, [@::].concat mixins

