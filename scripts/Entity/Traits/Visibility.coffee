
_ = require 'Utility/underscore'
Animation = require 'Graphics/Animation'
Debug = require 'Debug'
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Ticker = require 'Timing/Ticker'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = Visibility = class extends Trait
	
	Visibility = this
	Visibility.prefix = 'environment'
	qualifyWithPrefix = (index) -> "#{Visibility.prefix}-#{index}"
	
	stateDefaults: ->
		
		animations: {}
		animationIndex: 'initial'
		alpha: 1
		isVisible: true
		scale: [1, 1]
		preserveFrameWhenMoving: false

	initializeTrait: ->
		
		@animations = {}
		@animation = null
		@flashing = false
		@metadata = null
		
		animationPromises = for animationIndex, O of @state.animations
			
			O.animationUri = @entity.uri().replace(
				'.entity.json',
				'/' + animationIndex + '.animation.json'
			) unless O.animationUri?
			
			do (animationIndex, O) =>
				Animation.load(O.animationUri).then (animation) =>
					O.offset ?= [0, 0]
					
					@state.animations[animationIndex] = O
					@animations[animationIndex] = animation
					
					animation.setAsync false
					animation.start()
			
		Q.all animationPromises
	
	properties: ->
		
		alpha: {}
		animationIndex: {}
		isVisible: {}
		scale:
			set: (scale) -> @state.scale = Vector.copy scale
			eq: (l, r) -> Vector.equals l, r
				
	values: ->
		
		animation: -> @animation
		
		hasAnimationIndex: (animationIndex, qualify = true) ->
			animationIndex = qualifyWithPrefix animationIndex if qualify
			@animations[animationIndex]?
		
		scaleX: -> @state.scale[0]
		
		scaleY: -> @state.scale[1]
		
		visibleRect: -> Rectangle.compose(
			Vector.mul(
				Vector.scale Vector.add(
					Vector.scale @entity.size(), .5
					@metadata.offset
				), -1
				@state.scale
			)
			@animation?.frameSize() ? [0, 0]
		)
		
	actions: ->
		
		playAnimation: (plays = 1, reset = true) ->
			
			deferred = Q.defer()
			
			unless @animation?
				deferred.resolve()
				return deferred.promise
			
			@animation.on 'rolledOver.VisibilityTrait', =>
				if 0 is plays -= 1
					@animation.off 'rolledOver.VisibilityTrait'
					
					unless reset
						@animation.setIndex @animation.frameCount() - 1
					
					deferred.resolve()
				
			deferred.promise

		setScaleX: (x) -> @entity.setScale [x, @state.scale[1]]
			
		setScaleY: (y) -> @entity.setScale [@state.scale[0], y]

		stopAnimation: -> @animation?.stop()
		
		startAnimation: -> @animation?.start()
		
	signals: ->
		
		alphaChanged: ->
			for i, animation of @animations
				animation.setAlpha @state.alpha
		
		animationIndexChanged: ->
			
			qualifiedAnimationIndex = qualifyWithPrefix @state.animationIndex
			
			unless (animation = @animations[qualifiedAnimationIndex])?
				console.warn "Animation index '#{@state.animationIndex}' doesn't exist!"
				return
			
			@animation = animation
			@metadata = @state.animations[qualifiedAnimationIndex]
		
#		scaleChanged: ->
#			for i, animation of @animations
#				animation.setScale @state.scale
		
		isMovingChanged: ->
			
			if @entity.isMoving()
		
				index = if @state.preserveFrameWhenMoving
					@animation?.index()
				else
					0
				
				@entity.setAnimationIndex @entity.mobilityAnimationIndex()
				@animation?.setIndex index
				
			else
			
				@entity.setAnimationIndex 'initial'
			
		directionChanged: ->
			
			for i, animation of @animations
				animation.setDirection @entity.direction()
				
	handler: ->
		
		ticker: ->
			
			@flashingTicker?.tick()
			@animation?.tick()
		
		renderer:
			
			inline: (destination, camera) ->
				return unless @state.isVisible
				return if @state.alpha is 0
				
				position = Vector.add @entity.position(), @entity.offset()
				
				@animation?.setPosition Vector.add(
					Vector.sub position, camera
					Rectangle.position @entity.visibleRect()
				)
				
				alpha = @animation?.alpha()
				@animation?.setAlpha alpha * .5 if @flashing
				@animation?.setScale @state.scale
				
				@animation?.render destination
				
				@animation?.setAlpha alpha

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
				if animation.animationUri is "#{uri}/#{index}.animation.json"
					delete animation.animationUri
			
			delete state.animations if _.isEmpty state.animations
		
		O.state = state unless _.isEmpty state
		O
