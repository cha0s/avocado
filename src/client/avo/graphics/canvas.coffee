
uuid = require 'vendor/uuid'

FunctionExt = require 'avo/extension/function'
Vector = require 'avo/extension/vector'

Renderer = require 'avo/graphics/renderer'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

input = require 'avo/input'
Node = require 'avo/ui/node'

canvases = {}

module.exports = class AvoCanvas

  mixins = [
    EventEmitter

    Property(
      'verticalAlign'
      default: 'middle'
      set: (verticalAlign) ->
        if -1 is ['top', 'middle', 'bottom'].indexOf verticalAlign
          throw new Error "#{verticalAlign} is an invalid vertical alignment!"

        @_verticalAlign = verticalAlign
    )
  ]

  @lookup: (uuid) -> canvases[uuid]

  constructor: (resolution, renderer) ->
    mixin.call this for mixin in mixins

    @_renderer = new Renderer resolution, renderer

    @_calculatedSize = [0, 0]

    @_container = window.document.createElement 'div'
    @_container.style.position = 'absolute'
    @_container.style.overflow = 'hidden'
    @_container.appendChild @_renderer.element()

    uiContainer = window.document.createElement 'div'
    uiContainer.style.position = 'absolute'
    uiContainer.style.left = '0px'
    uiContainer.style.top = '0px'

    @_container.appendChild uiContainer

    @_uiContainerNode = new Node uiContainer
    @_uiContainerNode.show()

    @_renderer.element().dataset.uuid = @_uuid = uuid.v4()
    canvases[@_uuid] = this

  element: -> @_container

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

    switch @verticalAlign()
      when 'top'
        @_container.style.top = 0
      when 'middle'
        @_container.style.top = "#{offset[1]}px"
      when 'bottom'
        @_container.style.bottom = 0

    @_container.className = 'avo-canvas-container'

  scale: -> Vector.div @_renderer.size(), @_calculatedSize

  size: -> @_renderer.size()

  translateInput: (input) ->

    input.on '*', ->

      if -1 is ['mouseMove', 'mouseDown', 'mouseUp'].indexOf arguments[0]

        @emit.apply this, arguments

      else

        args = (arg for arg in arguments)

        event = args[args.length - 1]

        canvasTarget = false
        walk = event.target
        while walk
          if 'avo-canvas-container' is walk.className
            canvasTarget = true
            break
          walk = walk.parentNode
        return unless canvasTarget

        message = args[1]

        message.delta = Vector.mul message.delta, @scale() if message.delta?

        canvasDomRect = @_renderer.element().getBoundingClientRect()
        message.position = Vector.sub message.position, [
          canvasDomRect.left
          canvasDomRect.top
        ]
        message.position = Vector.mul message.position, @scale()

        @emit.apply this, args

    , this

  uiContainer: -> @_uiContainerNode.element()

  unlink: ->
    return unless canvases[@_uuid]?

    elm.parent.removeChild elm for elm in [
      @_container, @_renderer.element(), @_uiContainerNode.element()
    ]

    delete canvases[@_uuid]

  FunctionExt.fastApply Mixin, [@::].concat mixins

