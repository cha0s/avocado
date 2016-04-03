
_ = require 'avo/vendor/underscore'
Entity = require 'avo/entity'
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
Promise = require 'avo/vendor/bluebird'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'
VectorMixin = require 'avo/mixin/vector'

module.exports = Room = class Room

  @defaultLayerCount: 5

#  Physics = require "Physics/#{Config.Physics.Engine}"

  mixins = [
    EventEmitter
    Property 'name', ''
#    Property 'physics', new Physics()
    SizeProperty = VectorMixin 'size', 'width', 'height'
    TilesetProperty = Property 'tileset', null
  ]

  constructor: ->

    mixin.call @ for mixin in mixins

    @_collision = []
    # @_entitiesDestroyed = []
    @_entityDefinitions = []
    @_layers = for i in [0...Room.defaultLayerCount]
      new Room.TileLayer()

    # @on 'sizeChanged', => @_recomputeTotalSize()
    # @on 'tilesetChanged', => @_recomputeTotalSize()

  FunctionExt.fastApply Mixin, [@::].concat mixins

  fromObject: (O) ->

    @_entityDefinitions = O.entityDefinitions ? []

    # entityPromises = if (O.entities ?= []).length > 0

    #   promises = for entityO in O.entities
    #     Entity.load entityO.uri, entityO.traits ? []

    #   Promise.all(promises).then (entities) =>
    #     @_entities = []
    #     @addEntity entity for entity in entities

    #   promises
    # else
    #   []

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

  layerCount: -> @_layers.length

  loadEntities: ->

    return Promise.resolve [] if @_entityDefinitions.length is 0

    promises = for entityDefinition in @_entityDefinitions
      Entity.load entityDefinition.uri, entityDefinition.traits ? []

    Promise.all promises

  # _recomputeTotalSize: ->

#    @physics().setWalls @sizeInPx()
#    @physics().addFloor()

  # removeEntity: (entity) ->

  #   return if -1 is index = @_entities.indexOf entity

  #   @_entities.splice index, 1

  #   entity.off 'isDestroyedChanged.Room'

  #   @emit 'entityRemoved', entity

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

  # tick: ->

  #   if @_entitiesDestroyed.length > 0
  #     @removeEntity entity for entity in @_entitiesDestroyed
  #     @_entitiesDestroyed = []

#    @physics().tick()

  tileIndexFromPosition: (position, layerIndex = 0) ->

    @_layers[layerIndex].tileIndexFromPosition position

#  toImage: (tileset) ->
#
#    image = new Image @sizeInPx()
#    layer.render [0, 0], image for layer in @_layers
#    image

  toJSON: ->

    name: @name()
    size: @size()
    layers: _.map @_layers, (layer) -> layer.toJSON()
    collision: @_collision
    entities: @_entities
    tilesetUri: @tileset()?.uri()

Room.TileLayer = require './tileLayer'
Room.Tileset = require './tileset'
