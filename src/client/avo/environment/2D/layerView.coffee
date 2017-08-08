
PIXI = require 'vendor/pixi'

FunctionExt = require 'avo/extension/function'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

Container = require 'avo/graphics/container'
Image = require 'avo/graphics/image'
Renderer = require 'avo/graphics/renderer'
Sprite = require 'avo/graphics/sprite'
SpriteContainer = require 'avo/graphics/sprite-container'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

module.exports = class LayerView

  Mixin.toClass this, mixins = [
    EventEmitter

    VectorMixin(
      'position', 'x', 'y'
      x: default: 0
      y: default: 0
    )

    Property 'layer', default: null

    Property 'tileset', default: null
  ]

  constructor: (@chunkSize = [512, 512]) ->
    mixin.call this for mixin in mixins

    @_chunkMap = {}

    @_renderer = new Renderer [0, 0], 'canvas'
    @_container = new Container()
    @_spriteContainer = new Container()

    @_container.addChild @_spriteContainer

    @on 'layerChanged', @onLayerChanged.bind this
    @on 'positionChanged', @onPositionChanged.bind this

  container: -> @_container

  insertChunk: (position, chunk) ->
    chunkPosition = Vector.floor Vector.div position, @chunkSize
    [x, y] = chunkPosition

    @_chunkMap[y] ?= {}
    @_spriteContainer.removeChild @_chunkMap[y][x] if @_chunkMap[y][x]?

    # ###### TODO: Ugly.
    sprite = new Sprite _texture: chunk
    sprite.setPosition position
    @_spriteContainer.addChild @_chunkMap[y][x] = sprite

  onLayerChanged: (old, current) ->

    old?.off '.LayerView'

    current?.on 'tileIndexChanged.LayerView', @onLayerTileIndexChanged.bind this

    @renderChunks()

  onLayerTileIndexChanged: (position, tileIndex) ->
    return unless (tileset = @tileset())?

    position = Vector.mul position, tileset.tileSize()
    chunkPosition = Vector.floor Vector.div position, @chunkSize

    # ###### TODO: renderTo, when PIXI has good enough erasure support.
    # [cx, cy] = chunkPosition
    # chunk = @_chunkMap[cy]?[cx]
    # return unless chunk?

    # @renderTo(
    #   Rectangle.compose position, tileset.tileSize()
    #   chunk._sprite.texture
    #   Vector.mod position, @chunkSize
    # )

    chunkPosition = Vector.mul chunkPosition, @chunkSize
    @insertChunk chunkPosition, @renderChunk Rectangle.compose(
      chunkPosition
      @chunkSize
    )

  onPositionChanged: -> @_container.setPosition Vector.scale @position(), -1

  removeAllChunks: ->

    @_chunkMap = {}
    @_spriteContainer.removeAllChildren()

  renderTo: (rectangle, target, offset = [0, 0]) ->

    return unless layer = @layer()
    return if layer.isEmpty()

    return unless tileset = @tileset()
    return unless tileset.image()?

    sprite = new Sprite tileset.image()

    tileSize = tileset.tileSize()

    offset = Vector.add offset, Vector.scale(
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

        if index = layer.tileIndexAt start

          tileBox = tileset.tileBox index

          sprite.setPosition offset
          sprite.setSourceRectangle tileBox

          @_renderer.render sprite, target

        offset[0] += tileSize[0]
        start[0] += 1

      offset[0] -= tileSize[0] * area[0]
      offset[1] += tileSize[1]

      start[0] -= area[0]
      start[1] += 1

    return

  renderChunk: (rectangle) ->

    texture = new PIXI.RenderTexture.create rectangle[2], rectangle[3]

    @renderTo rectangle, texture

    return texture

  renderChunks: ->

    chunkArea = Vector.ceil Vector.div(
      @sizeInPx()
      @chunkSize
    )

    @removeAllChunks()

    for y in [0...chunkArea[1]]
      @_chunkMap[y] ?= {}

      for x in [0...chunkArea[0]]
        position = Vector.mul [x, y], @chunkSize

        chunk = @renderChunk Rectangle.compose(
          position
          @chunkSize
        )

        @insertChunk position, chunk

    return

  sizeInPx: ->

    return [0, 0] unless tileset = @tileset()
    return [0, 0] unless layer = @layer()

    return Vector.mul layer.size(), tileset.tileSize()
