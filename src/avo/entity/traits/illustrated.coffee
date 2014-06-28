
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
			O.uri = @entity.uri().replace(
				'.entity.json',
				'/' + imageIndex + '.png'
			) unless O.uri?
			
			do (imageIndex, O) =>
				Image.load(O.uri).then (image) =>
					
					@_sprites[imageIndex] = new Sprite image
					@_sprites[imageIndex].setOrigin(
						O.origin ? Vector.scale image.size(), .5
					)
					
		Promise.all imagePromises
	
	_setImagePosition: (imageIndex, position) ->
	
		@_sprites[imageIndex].setPosition Vector.add(
			position
			Vector.scale(
				@state.images[imageIndex].offset ? [0, 0]
				-1
			)
		)
	
	_snapPosition: ->
		for i, sprite of @_sprites
			@_setImagePosition i, @entity.position()
			
	_snapRotation: ->
		for i, sprite of @_sprites
			sprite.setRotation @entity.rotation()
			
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
	
	values: ->
		
		image: -> @_sprites[@state.imageIndex].image() 

	toJSON: ->
		
		O = super
		return O unless O.state?
		
		state = O.state
		delete O.state
		
		# Delete image URIs that are just using the entity's uri, since
		# that's the default.
		if state.images?
			uri = @entity.uri().replace '.entity.json', ''
			
			for index, image of state.images
				if image.uri is "#{uri}/#{index}.png"
					delete image.uri
			
			delete state.images if _.isEmpty state.images
		
		O.state = state unless _.isEmpty state
		O
