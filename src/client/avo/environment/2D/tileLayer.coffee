# **TileLayer** represents a 2D tile matrix. It is a glorified array of
# tile indices which index into a tileset.

Promise = require 'vendor/bluebird'

Vector = require 'avo/extension/vector'

Packer = require 'avo/fs/packer'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

module.exports = Mixin.toClass [

  EventEmitter

  SizeProperty = VectorMixin 'size', 'width', 'height'

], class TileLayer

  constructor: (size = [0, 0]) ->

    # The tile index data.
    area = Vector.area size
    @_tileIndices = if 0 is area
      null
    else
      0 for i in [0...area]

    @setSize size

  fromObject: (O) ->

    @setSize O.size

    @_tileIndices = if O.tileIndices?
      Packer.unpack O.tileIndices
    else
      (0 for i in [0...Vector.area @size()])

    return Promise.resolve this

  toJSON: ->

    tileIndices = if @isEmpty()
      null
    else
      Packer.pack @_tileIndices

    tileIndices: tileIndices
    size: @size()

  # Calculate the area of the tile layer.
  area: -> Vector.area @size()

  isEmpty: ->

    return false if @_tileIndices?
    return false if tileIndex > 0 for tileIndex in @_tileIndices
    return true

  layerIndexAt: (position) ->

    layerIndex = position[1] * @width() + position[0]

    return null if layerIndex < 0
    return null if layerIndex >= @_tileIndices.length

    return layerIndex

  positionIsWithinLayer: (position) ->

  # Resize the layer, losing as little information as possible.
  setSize: (size) ->
    SizeProperty::setSize.call this, size

    return if Vector.equals @size(), size

    tileIndices = new Array Vector.area size
    for y in [0...size[1]]
      for x in [0...size[0]]
        tileIndices[y * size[0] + x] = @tileIndexAt [x, y]

    @setSize size
    @_tileIndices = tileIndices

    return

  setTileIndexAt: (position, index) ->

    return unless @_tileIndices?

    return unless (layerIndex = @layerIndexAt position)?
    @_tileIndices[layerIndex] = index

    @emit 'tileIndexChanged', position, index

  # Retrieve a tile index at a position within the layer.
  tileIndexAt: (position) ->

    return null unless @_tileIndices?

    return unless (layerIndex = @layerIndexAt position)?
    return @_tileIndices[layerIndex]
