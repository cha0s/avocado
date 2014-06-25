
Promise = require 'avo/vendor/bluebird'

Animation = require 'avo/graphics/animation'

Trait = require './trait'

module.exports = class Animated extends Trait
	
	@dependencies: [
		'visible'
	]
	
	stateDefaults: ->
		
		animations: {}
		animationIndex: 'initial'
		preserveFrameWhenMoving: false
		
	initialize: ->
		
		@_animations = {}
		@_localContainer = null
		
		animationPromises = for animationIndex, O of @state.animations
			
			# Look for animations in the entity directory if no URI was
			# explicitly given.
			O.uri = @entity.uri().replace(
				'.entity.json',
				'/' + animationIndex + '.animation.json'
			) unless O.uri?
			
			do (animationIndex, O) =>
				Animation.load(O.uri).then (animation) =>
					
					@_animations[animationIndex] = animation
					
					animation.setAsync false
					animation.start()
			
		Promise.all animationPromises
	
	properties: ->
		
		animationIndex: {}
				
	signals: ->
		
		addToLocalContainer: (@_localContainer) ->
			
			@_localContainer.addChild @_animations[@state.animationIndex].sprite()
			
		animationIndexChanged: (oldIndex) ->
			
			@_localContainer.removeChild @_animations[oldIndex].sprite()
			@_localContainer.addChild @_animations[@state.animationIndex].sprite()
			
		directionChanged: ->

			for i, animation of @_animations
				animation.setDirection @entity.direction()
				
		isMovingChanged: ->
			
			if @entity.isMoving()
		
				index = if @state.preserveFrameWhenMoving
					@entity.animation()?.index()
				else
					0
				
				@entity.setAnimationIndex @entity.mobilityAnimationIndex()
				@entity.animation()?.setIndex index
				
			else
			
				@entity.setAnimationIndex 'initial'
			
		positionChanged: ->

			for i, animation of @_animations
				animation.setPosition @entity.position()

	values: ->
		
		animation: -> @_animations[@state.animationIndex] 

	handler: ->
		
		ticker: ->
			
			@entity.animation()?.tick()
			
	toJSON: ->
		
		O = super
		return O unless O.state?
		
		state = O.state
		delete O.state
		
		# Delete animation URIs that are just using the entity's uri, since
		# that's the default.
		if state.animations?
			uri = @entity.uri().replace '.entity.json', ''
			
			for index, animation of state.animations
				if animation.uri is "#{uri}/#{index}.animation.json"
					delete animation.uri
			
			delete state.animations if _.isEmpty state.animations
		
		O.state = state unless _.isEmpty state
		O
