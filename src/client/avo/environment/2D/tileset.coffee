
Promise = require 'vendor/bluebird'

fs = require 'avo/fs'

Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

AvoImage = require 'avo/graphics/image'
Sprite = require 'avo/graphics/sprite'

EventEmitter = require 'avo/mixin/eventEmitter'
Lfo = require 'avo/mixin/lfo'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

module.exports = Mixin.toClass [

  EventEmitter

  ImageProperty = Property 'image', default: null

  Property 'name', default: ''

  VectorMixin(
    'tileSize', 'tileWidth', 'tileHeight'
    tileWidth: default: 0, tileHeight: default: 0
  )

], class Tileset

  @load: (uri) -> fs.readJsonResource(uri).then (O) ->
    O.uri = uri
    (new module.exports()).fromObject O

  constructor: ->

    @_tileBoxCache = []
    @_uri = null

    @on 'imageChanged', @onImageChanged.bind this
    @on 'tileSizeChanged', @onTileSizeChanged.bind this

  fromObject: (O) ->

    @_uri = O.uri

    @setName O.name ? ''
    @setTileSize O.tileSize ? [0, 0]

    imagePromise = if O.image?
      Promise.resolve O.image
    else
      AvoImage.load O.imageUri ? O.uri.replace '.tileset.json', '.png'

    imagePromise.then(@setImage.bind this).then => this

  toJSON: ->

    tileSize: Vector.copy @tileSize()
    name: @name()

  isValid: ->
    return false unless @image()?
    return not Vector.isNull @image().size()

  onImageChanged: -> @_resetTileBoxCache()

  onTileSizeChanged: -> @_resetTileBoxCache()

  sizeInTiles: -> Vector.div @image().size(), @tileSize()

  tileBox: (index) -> @_tileBoxCache[index]

  tileCount: -> Vector.area @sizeInTiles()

  uri: -> @_uri

  _resetTileBoxCache: ->
    return unless @isValid()

    tiles = Vector.div @image().size(), tileSize = @tileSize()

    @_tileBoxCache = []
    @_tileBoxCache[i] = Rectangle.compose(
      Vector.mul [i % tiles[0], Math.floor i / tiles[0]], tileSize
      tileSize
    ) for i in [0...Vector.area tiles]
