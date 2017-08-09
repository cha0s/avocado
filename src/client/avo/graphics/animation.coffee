
#Core = require 'avo/core'
#Graphics = require 'avo/graphics'

_ = require 'vendor/underscore'
Promise = require 'vendor/bluebird'

Rectangle = require 'avo/extension/rectangle'
String = require 'avo/extension/string'
Vector = require 'avo/extension/vector'

fs = require 'avo/fs'

EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
TimedIndex = require 'avo/mixin/timedIndex'
VectorMixin = require 'avo/mixin/vector'

Image = require 'avo/graphics/image'
Sprite = require 'avo/graphics/sprite'

module.exports = Mixin.toClass [

  EventEmitter
  DirectionProperty = Property 'direction', default: 0
  Property 'directionCount', default: 1
  Property 'frameSize', default: [0, 0]
  ImageProperty = Property 'image', default: null
  VectorMixin(
    'position', 'x', 'y'
    x: default: 0
    y: default: 0
  )
  TimedIndex 'frame'
  Property 'uri', default: ''

], class Animation

  @load: (uri) ->

    unless uri.match '.animation.json'
      uri += '/index.animation.json'

    promise = fs.readJsonResource(uri).then (O) ->
      O.uri = uri
      (new Animation()).fromObject O

  constructor: ->

    @_interval = null
    @_sprite = null

    @on 'imageChanged', =>
      if @_sprite?
        @_sprite.setSource @image()
      else
        @_sprite = new Sprite @image()

    @on 'positionChanged', => @_sprite.setPosition @position()

    @on(
      [
        'directionChanged'
        'frameSizeChanged'
        'imageChanged'
        'indexChanged'
      ]
      => @_sprite.setSourceRectangle @sourceRectangle()
    )

  fromObject: (O) ->

    O.imageUri ?= O.uri.replace '.animation.json', '.png'
    for property in [
      'directionCount', 'frameCount', 'frameRate', 'frameSize', 'uri'
    ]
      @[String.setterName property] O[property] if O[property]?

    Image.load(O.imageUri).then (image) =>

      @setImage image, O.frameSize

      this

  clampDirection: (direction) ->

    return 0 if @directionCount() is 1

    direction = Math.min 7, Math.max direction, 0
    direction = {
      4: 1
      5: 1
      6: 3
      7: 3
    }[direction] if @directionCount() is 4 and direction > 3

    direction

  render: (
    destination
    index
  ) ->

    return unless @frameCount() > 0
    return unless @image()?

    if (index ?= @index()) isnt @index()
      @_sprite.setSourceRectangle @sourceRectangle index

    @_sprite.setScale @scale()

    @_sprite.renderTo destination

  setDirection: (direction) ->
    DirectionProperty::setDirection.call(
      @
      @clampDirection direction
    )

  setImage: (
    image
    frameSize
  ) ->
    ImageProperty::setImage.call this, image

    # If the frame size isn't explicitly given, then calculate the
    # size of one frame using the total number of frames and the total
    # spritesheet size. Width is calculated by dividing the total
    # spritesheet width by the number of frames, and the height is the
    # height of the spritesheet divided by the number of directions
    # in the animation.
    @setFrameSize frameSize ? Vector.div(
      @image().size()
      [@frameCount(), @directionCount()]
    )

    return

  sourceRectangle: (index) ->

    Rectangle.compose(
      Vector.mul @frameSize(), [
        (index ? @index()) % @frameCount()
        @direction()
      ]
      @frameSize()
    )

  sprite: -> @_sprite

  toJSON: ->

    defaultImageUri = @uri().replace '.animation.json', '.png'
    imageUri = @image().uri() if @image().uri() isnt defaultImageUri

    directionCount: @directionCount()
    frameRate: @frameRate()
    frameCount: @frameCount()
    frameSize: @frameSize()
    imageUri: imageUri
