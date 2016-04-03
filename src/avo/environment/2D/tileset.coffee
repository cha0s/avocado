
#Graphics = require 'avocado/Graphics'

fs = require 'avo/fs'
AvoImage = require 'avo/graphics/image'
Promise = require 'avo/vendor/bluebird'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

module.exports = Tileset = class

  @load: (uri) ->
    fs.readJsonResource(uri).then (O) ->
      O.uri = uri
      tileset = new Tileset()
      tileset.fromObject O

  constructor: ->

    @image_ = null
    @tileSize_ = [0, 0]
    @tileBoxCache_ = []
    @tiles_ = [0, 0]
    @name_ = ''
    @description_ = ''

  fromObject: (O) ->

    @["#{i}_"] = O[i] for i of O

    imagePromise = if O.image?
      Promise.resolve O.image
    else
      AvoImage.load O.imageUri ? O.uri.replace '.tileset.json', '.png'

    imagePromise.then (@image_) =>

      @setImage @image_
      this

  toJSON: ->

    tileSize: Vector.copy @tileSize_
    name: @name_
    description: @description_

  copy: ->
    tileset = new Tileset()
    tileset.fromObject @toJSON()
    tileset

  description: -> @description_
  setDescription: (@description_) ->

  name: -> if @name_ is '' then @uri_ else @name_
  setName: (@name_) ->

  tileSize: -> @tileSize_

  tileWidth: -> @tileSize_[0]
  tileHeight: -> @tileSize_[1]

  setImage: (@image_) -> @setTileSize @tileSize_

  setTileSize: (w, h) ->

    @tileSize_ = if h? then [w, h] else w

    return unless @image_?

    @tiles_ = Vector.div @image_.size(), @tileSize_

    # Warm up the tile box cache.
    @tileBoxCache_ = []
    for i in [0...Vector.area @tiles_]
      @tileBox i

    return

  setTileWidth: (width) -> @setTileSize width, @tileSize_[1]
  setTileHeight: (height) -> @setTileSize @tileSize_[0], height

  tiles: -> @tiles_

  render: (
    location
    destination
    index
    mode
    tileClip = [0, 0, @tileSize_[0], @tileSize_[1]]
  ) ->

    return unless @image_?

    tileBox = @tileBox index
    tileBox = Rectangle.intersection(
      tileBox
      Rectangle.translated tileClip, Rectangle.position tileBox
    )

    sprite = new Graphics.Sprite()
    sprite.setSource @image_
    sprite.setPosition Vector.add location, Rectangle.position tileClip
    sprite.setSourceRectangle tileBox
    sprite.renderTo destination

  image: -> @image_

  uri: -> @uri_

  isValid: ->
    return false unless @image_?

    not Vector.isNull @image_.size()

  tileBox: (index) ->

    @tileBoxCache_[index] = Rectangle.compose(
      Vector.mul(
        [index % @tiles_[0], Math.floor index / @tiles_[0]]
        @tileSize_
      )
      @tileSize_
    ) unless @tileBoxCache_[index]?

    @tileBoxCache_[index]

  tileCount: -> Vector.area @tiles_
