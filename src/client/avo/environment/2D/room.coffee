
_ = require 'vendor/underscore'
Entity = require 'avo/entity'
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
Promise = require 'vendor/bluebird'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'
VectorMixin = require 'avo/mixin/vector'

module.exports = Room = class Room

  @defaultLayerCount: 5

  mixins = [
    EventEmitter
    Property 'name', default: ''
    SizeProperty = VectorMixin(
      'size', 'width', 'height'
      width: default: 0
      height: default: 0
    )
    TilesetProperty = Property 'tileset', default: null
  ]

  constructor: ->

    mixin.call @ for mixin in mixins

    @_collision = []
    @_entityDefinitions = []
    @_layers = for i in [0...Room.defaultLayerCount]
      new Room.TileLayer()

  FunctionExt.fastApply Mixin, [@::].concat mixins

  fromObject: (O) ->

    @_entityDefinitions = O.entityDefinitions ? []

    layerPromises = if (O.layers ?= []).length > 0

      promises = for layerO in O.layers
        (new Room.TileLayer()).fromObject layerO

      Promise.all(promises).then (layers) => @_layers = layers

      promises
    else
      []

    @setName O.name

    tilesetPromise = if O.tilesetUri?
      Room.Tileset.load O.tilesetUri
    else
      O.tileset
    Promise.cast(tilesetPromise).then (tileset) =>
      @setTileset tileset

    promises = [
      tilesetPromise
    ].concat(
      # entityPromises
      layerPromises
    )

    Promise.all(promises).then =>
      @setSize O.size
      @

  layer: (index) -> @_layers[index]

  layers: -> @_layers

  layerCount: -> @_layers.length

  loadEntities: ->

    return Promise.resolve [] if @_entityDefinitions.length is 0

    promises = for entityDefinition in @_entityDefinitions
      Entity.load entityDefinition.uri, entityDefinition.traits ? []

    Promise.all promises

  setSize: (size) ->

    SizeProperty::setSize.call @, size

    layer.setSize size for layer in @_layers

  setTileset: (tileset) ->

    TilesetProperty::setTileset.call @, tileset

    layer.setTileset tileset for layer in @_layers

  sizeInPx: ->

    Vector.mul(
      @size()
      @tileset()?.tileSize() ? [0, 0]
    )

  tileIndexFromPosition: (position, layerIndex = 0) ->

    @_layers[layerIndex].tileIndexFromPosition position

  toJSON: ->

    name: @name()
    size: @size()
    layers: _.map @_layers, (layer) -> layer.toJSON()
    collision: @_collision
    entities: @_entities
    tilesetUri: @tileset()?.uri()

Room.TileLayer = require './tileLayer'
Room.Tileset = require './tileset'
