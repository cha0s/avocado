
_ = require 'Utility/underscore'
Animation = require 'Graphics/Animation'
Debug = require 'Debug'
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = Visibility = class extends Trait
	
	Visibility = this
	Visibility.prefix = 'environment'
	qualifyWithPrefix = (index) -> "#{Visibility.prefix}-#{index}"
	
	stateDefaults: ->
		
		animations: {}
		isVisible: true
		index: 'initial'
		alpha: 255
		preserveFrameWhenMoving: false

	toJSON: ->
		
		O = super
		
		return O unless O.state?
		
		state = O.state
		delete O.state
		
		# Delete animation URIs that are just using the entity's uri, since
		# that's the default.
		if state.animations?
			uri = @entity.uri.replace '.entity.json', ''
			
			for index, animation of state.animations
				if animation.animationUri is "#{uri}/#{index}.animation.json"
					delete animation.animationUri
			
			if _.isEmpty state.animations
				delete state.animations
		
		O.state = state unless _.isEmpty state
		O
	
	resetTrait: ->
		
		@animationPlays = 0
	
		@entity.setCurrentAnimationIndex @entity.currentAnimationIndex()
		
	initializeTrait: ->
		
		@animationObjects ?= {}
		
		animationPromises = for index, animation of @state.animations
			
			unless animation.animationUri?
				
				animation.animationUri = @entity.uri.replace(
					'.entity.json',
					'/' + index + '.animation.json'
				)
			
			((animation, index) =>
				Animation.load(animation.animationUri).then (animationObject) =>
					animation.object = animationObject
					@setAnimation index, animation
					delete animation.object
			) animation, index
			
		Q.all animationPromises
	
	currentAnimation: ->
		@animationObjects[qualifyWithPrefix @state.index]
		
	currentAnimationMetadata: -> 
		@state.animations[qualifyWithPrefix @state.index]
	
	currentAnimationFrameSize: ->
		@currentAnimation().frameSize()
	
	removeAnimationIndex: (index) ->
		delete @state.animations[index]
		delete @animationObjects[index]
	
	renderCurrentAnimation: (position, buffer, alpha = @state.alpha, clip) ->
		return if alpha is 0
		
		@currentAnimation().render(
			position
			buffer
			alpha
			null
			clip
		)

	setAnimation: (index, animation) ->
		
		animation.object.on 'ticked.VisibilityTrait', =>
			@entity.emit 'renderUpdate'
		
		@state.animations[index] ?= {}
		@state.animations[index].offset = animation.offset ? [0, 0]
		
		@animationObjects[index] ?= {}
		@animationObjects[index] = animation.object
		
	visibleRect: -> Rectangle.compose(
		Vector.scale Vector.add(
			Vector.scale @entity.size(), .5
			@currentAnimationMetadata().offset
		), -1
		@currentAnimationFrameSize()
	)
	
	values: ->
	
		alpha: -> @state.alpha
		
		hasAnimationIndex: (index, qualify = true) ->
			index = qualifyWithPrefix index if qualify
			@animationObjects[index]?
		
		currentAnimationIndex: -> @state.index
		
		isVisible: -> @state.isVisible
	
	actions: ->
		
		setAlpha: (alpha) -> @state.alpha = alpha
		
		setIsVisible:
			argTypes: ['Boolean']
			argNames: ['Is visible']
			renderer: (candidate, args) ->
				
				output = "set #{candidate} visibility to "
				output += "#{Rule.Render args[0]}"
				
			name: 'Set is visible'
			f: (isVisible) -> @state.isVisible = isVisible
		
		setCurrentAnimationIndex:
			
			argTypes: ['String', 'Boolean', 'Boolean']
			argNames: ['Animation index', 'Reset to first frame', 'Start it']
			renderer: (candidate, args) ->
				
				output = "set #{candidate} animation index to "
				output += "#{Rule.Render args[0]} and reset to the first "
				output += "frame if #{Rule.Render args[1]}, "
				output += "starting it if #{Rule.Render args[2]}"
				
			name: 'Set animation index'
			f: (index, reset = true, start = true) ->
			
				if @state.index is index
					
					@currentAnimation()?.setCurrentFrameIndex 0 if reset
					
					if start
						
						unless @currentAnimation()?.isRunning()
						
							@currentAnimation()?.start false
							
				else 
				
					@currentAnimation().stop() if @currentAnimation()?.isRunning()
					
					@state.index = index
					
					@currentAnimation()?.setCurrentFrameIndex 0 if reset
					
					@currentAnimation()?.start false if start
					
				@entity.emit 'renderUpdate'
		
		playAnimation:
			
			argTypes: ['Number', 'Boolean']
			argNames: ['Number of plays', 'Reset to first frame at the end']
			renderer: (candidate, args) ->
				
				output = "play #{candidate} current animation "
				output += "#{Rule.Render args[0]} time(s), and reset to the"
				output += " first frame afterward if #{Rule.Render args[0]}"
				
			name: 'Play animation'
			f: (plays, reset) ->
				
				animation = @currentAnimation()
				
				if @animationPlays is 0
					@animationPlays = plays + 1
				
					animation.off 'rolledOver.VisibilityTrait'
					animation.on 'rolledOver.VisibilityTrait', =>
						@animationPlays -= 1
						
						if @animationPlays is 1
							animation.stop()
							animation.setCurrentFrameIndex animation.frameCount - 1 unless reset
						
					animation.start false
				
				if @animationPlays is 1
					
					@animationPlays = 0
					animation.off 'rolledOver.VisibilityTrait'
					
					increment: 1
					
				else 
					
					increment: 0
		
		stopCurrentAnimation: -> @currentAnimation().stop()
		
		startCurrentAnimation: -> @currentAnimation().start false
		
	signals: ->
		
		startedMoving: ->
			
			frameIndex = if @state.preserveFrameWhenMoving
				@currentAnimation().currentFrameIndex
			else
				0
			
			@entity.setCurrentAnimationIndex @entity.visibilityIndex(), false
			@currentAnimation().setCurrentFrameIndex frameIndex
		
		moving: (hypotenuse) ->
			@entity.setCurrentAnimationIndex @entity.visibilityIndex(), false
			
		stoppedMoving: ->
			@entity.setCurrentAnimationIndex 'initial', false
		
		directionChanged: (direction) ->
			for index, animation of @animationObjects
				animation.setCurrentDirection direction

	handler: ->
		
		ticker: ->
			
			@currentAnimation().tick()
		
		renderer: (destination, camera) ->
			return unless @state.isVisible
			
			position = Vector.sub @entity.position(), camera
			
			@renderCurrentAnimation(
				Vector.add position, Rectangle.position @visibleRect()
				destination
				@state.alpha
			)
			
			if Debug.isDebugging()
				destination.drawFilledBox(
					Rectangle.compose(
						Vector.sub position, Vector.scale @entity.size(), .5
						@entity.size()
					)
					255, 255, 255, 180
				)
