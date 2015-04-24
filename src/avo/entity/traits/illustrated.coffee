
_ = require 'avo/vendor/underscore'
Promise = require 'avo/vendor/bluebird'

Vector = require 'avo/extension/vector'

Image = require 'avo/graphics/image'
Sprite = require 'avo/graphics/sprite'

Trait = require './trait'

module.exports = class Illustrated extends Trait

  @dependencies: [
  	'corporeal'
  	'visible'
  ]

  constructor: ->
  	super

  	@_sprites = {}

  stateDefaults: ->

  	images: {}
  	imageIndex: 'initial'

  initialize: ->

  	imagePromises = for imageIndex, O of @state.images

  		# Look for images in the entity directory if no URI was
  		# explicitly given.
  		unless O.uri?
  			O.uri = "#{@entity.uri()}/illustrations/#{imageIndex}.png"

  		do (imageIndex, O) =>
  			Image.load(O.uri).then (image) =>

  				@_sprites[imageIndex] = new Sprite image
  				@_sprites[imageIndex].setOrigin(
  					O.origin ? Vector.scale image.size(), .5
  				)

  	Promise.all imagePromises

  _snapPosition: ->

  	for i, sprite of @_sprites
  		sprite.setPosition Vector.add(
  			@entity.position()
  			Vector.scale(
  				Vector.add(
  					@entity.offset()
  					@state.images[i].offset ? [0, 0]
  				)
  				-1
  			)
  		)

  	return

  _snapRotation: ->

  	for i, sprite of @_sprites
  		sprite.setRotation @entity.rotation()

  	return

  properties: ->

  	imageIndex: {}

  signals: ->

  	traitsChanged: ->

  		@_snapPosition()
  		@_snapRotation()

  	addToLocalContainer: (localContainer) ->

  		for i, sprite of @_sprites
  			sprite.setIsVisible false
  			localContainer.addChild sprite

  		@_sprites[@state.imageIndex].setIsVisible true

  	imageIndexChanged: (oldIndex) ->

  		@_sprites[oldIndex].setIsVisible false
  		@_sprites[@state.imageIndex].setIsVisible true

  	positionChanged: -> @_snapPosition()

  	rotationChanged: ->	@_snapRotation()

  actions: ->

  	setScaleX: (x) -> @_sprites[@state.imageIndex].setScaleX x

  	setScaleY: (y) -> @_sprites[@state.imageIndex].setScaleY y

  	setTintRed: (red) -> @_sprites[@state.imageIndex].setTintRed red

  	setTintGreen: (green) -> @_sprites[@state.imageIndex].setTintGreen green

  	setTintBlue: (blue) -> @_sprites[@state.imageIndex].setTintBlue blue

  	setTint: (color) -> @_sprites[@state.imageIndex].setTint color

  values: ->

  	image: -> @_sprites[@state.imageIndex].image()

  	scaleX: -> @_sprites[@state.imageIndex].scaleX()

  	scaleY: -> @_sprites[@state.imageIndex].scaleY()

  	tintRed: -> @_sprites[@state.imageIndex].tintRed()

  	tintGreen: -> @_sprites[@state.imageIndex].tintGreen()

  	tintBlue: -> @_sprites[@state.imageIndex].tintBlue()

  	tint: -> @_sprites[@state.imageIndex].tint()

  toJSON: ->

  	O = super
  	return O unless O.state?

  	state = O.state
  	delete O.state

  	# Delete image URIs that are just using the entity's uri, since
  	# that's the default.
  	if state.images?
  		uri = @entity.uri().replace 'index.entity.json', 'illustrations'

  		for index, image of state.images
  			if image.uri is "#{uri}/#{index}.png"
  				delete image.uri

  		delete state.images if _.isEmpty state.images

  	O.state = state unless _.isEmpty state
  	O
