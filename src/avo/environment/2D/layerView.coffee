
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Image = require 'avo/graphics/image'
Mixin = require 'avo/mixin'
PIXI = require 'avo/vendor/pixi'
Property = require 'avo/mixin/property'
Rectangle = require 'avo/extension/rectangle'
Sprite = require 'avo/graphics/sprite'
SpriteContainer = require 'avo/graphics/spriteContainer'
Vector = require 'avo/extension/vector'
VectorMixin = require 'avo/mixin/vector'

module.exports = class LayerView

  mixins = [
    EventEmitter
    PositionProperty = VectorMixin(
      'position', 'x', 'y'
      x: default: 0
      y: default: 0
    )
    LayerProperty = Property 'layer', default: null
  ]

  constructor: (@_renderer) ->
    mixin.call @ for mixin in mixins

    @_container = new SpriteContainer()

    @on 'positionChanged', (oldPosition) =>
      return unless @_container?

      @_container.setPosition Vector.scale @position(), -1

    @on 'layerChanged', (oldSize) =>

      @renderChunks()

  FunctionExt.fastApply Mixin, [@::].concat mixins

  container: -> @_container

  renderChunk: (rectangle) ->
    return unless @_layer.tileIndices_?
    return unless (tileset = @_layer.tileset())?
    return unless tileset.image()?

    texture = new PIXI.RenderTexture @_renderer.renderer(), rectangle[2], rectangle[3]

    container = new PIXI.Container()
    sprite = new Sprite @_layer.tileset().image()
    container.addChild sprite.internal()

    tileSize = @_layer.tileset_.tileSize()

    offset = Vector.scale(
      Vector.mod rectangle, tileSize
      -1
    )

    start = Vector.floor Vector.div rectangle, tileSize

    area = Vector.floor Vector.div(
      Rectangle.size rectangle
      tileSize
    )

    for i in [0..1]
      area[i] += 2

    for y in [0...area[1]]

      for x in [0...area[0]]

        if index = @_layer.tileIndex start

          tileBox = tileset.tileBox index

          sprite.setPosition offset
          sprite.setSourceRectangle tileBox

          texture.render container

        offset[0] += tileSize[0]
        start[0] += 1

      offset[0] -= tileSize[0] * area[0]
      offset[1] += tileSize[1]

      start[0] -= area[0]
      start[1] += 1

    Image.fromTexture texture

  renderChunks: ->

    chunkSize = [1024, 1024]

    chunkArea = Vector.ceil Vector.div(
      @_layer.sizeInPx()
      chunkSize
    )

    for y in [0...chunkArea[1]]
      for x in [0...chunkArea[0]]

        position = Vector.mul [x, y], chunkSize

        sprite = new Sprite @renderChunk Rectangle.compose(
          position
          chunkSize
        )

        sprite.setPosition position

        @_container.addChild sprite

    return
