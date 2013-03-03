
_ = require 'Utility/underscore'
Animation = require 'Graphics/Animation'
Rectangle = require 'Extension/Rectangle'
Trait = require 'Entity/Traits/Trait'
upon = require 'Utility/upon'
Vector = require 'Extension/Vector'

module.exports = Visibility = class extends Trait
	
	Visibility = this
	Visibility.prefix = 'environment'
	qualifyWithPrefix = (index) -> "#{Visibility.prefix}-#{index}"
	
	defaults: ->
		
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
				if animation.uri is uri + '/' + index + '.animation.json'
					delete animation.uri
			
			if _.isEmpty state.animations
				delete state.animations
		
		O.state = state unless _.isEmpty state
		O
	
	resetTrait: ->
		
		@state.animationPlays = 0
	
		@entity.setCurrentAnimationIndex @entity.currentAnimationIndex()
		
	initializeTrait: ->
		defer = upon.defer()
		
		@animationObjects ?= {}
		
		promiseAnimation = (animation, index) =>
			
			Animation.load(animation.animationUri).then (animationObject) =>
			
				animation.object = animationObject
				
				@entity.setAnimation index, animation
		
		animationPromises = for index, animation of @state.animations
			
			unless animation.animationUri?
				
				animation.animationUri = @entity.uri.replace(
					'.entity.json',
					'/' + index + '.animation.json'
				)
			
			promiseAnimation animation, index
			
		upon.all(animationPromises).then =>
			
			@resetTrait()
			
			defer.resolve()
		
		defer.promise
		
	values: ->
	
		alpha: -> @state.alpha
		
		visibleRect: ->
			
			Rectangle.compose(
				Vector.scale Vector.add(
					Vector.scale @entity.size(), .5
					@entity.currentAnimationMetadata().offset
				), -1
				@entity.currentAnimationFrameSize()
			)
		
		hasAnimationIndex: (index, qualify = true) ->
			
			index = qualifyWithPrefix index if qualify
			
			@animationObjects[index]?
		
		setAnimation: (index, animation) ->
			
			animation.object.on 'ticked.VisibilityTrait', =>
				
				@entity.emit 'renderUpdate'
			
			@state.animations[index] ?= {}
			@state.animations[index].offset = animation.offset ? [0, 0]
			
			@animationObjects[index] ?= {}
			@animationObjects[index] = animation.object
			
		removeAnimationIndex: (index) ->
			
			delete @state.animations[index]
			delete @animationObjects[index]
		
		currentAnimationIndex: -> @state.index
		currentAnimation: ->
			
			@animationObjects[qualifyWithPrefix @state.index]
			
		currentAnimationMetadata: ->
			
			@state.animations[qualifyWithPrefix @state.index]
		
		currentAnimationFrameSize: -> @entity.currentAnimation().frameSize()
		
		isVisible: -> @state.isVisible
	
	actions: ->
		
		setAlpha: (alpha) -> @state.alpha = alpha
		
		renderCurrentAnimation: (position, clip, buffer, alpha = @state.alpha) ->
			return if alpha is 0
			
			@entity.currentAnimation().render(
				position
				buffer
				alpha
				null
				clip
			)
		
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
					
					@entity.currentAnimation()?.setCurrentFrameIndex 0 if reset
					
					if start
						
						unless @entity.currentAnimation()?.isRunning()
						
							@entity.currentAnimation()?.start()
							
				else 
				
					@entity.currentAnimation().stop() if @entity.currentAnimation()?.isRunning()
					
					@state.index = index
					
					@entity.currentAnimation()?.setCurrentFrameIndex 0 if reset
					
					@entity.currentAnimation()?.start() if start
					
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
				
				animation = @entity.currentAnimation()
				
				if @state.animationPlays is 0
					
					@state.animationPlays = plays + 1
				
					animation.off 'rolledOver.Visibility::playAnimation'
					animation.on 'rolledOver.Visibility::playAnimation', =>
						
						@state.animationPlays -= 1
						
						if @state.animationPlays is 1
							
							animation.stop()
							
							animation.setCurrentFrameIndex animation.frameCount - 1 unless reset
						
					animation.start()
				
				if @state.animationPlays is 1
					
					@state.animationPlays = 0
					animation.off 'rolledOver.Visibility::playAnimation'
					
					increment: 1
					
				else 
					
					increment: 0
		
		stopCurrentAnimation: -> @entity.currentAnimation().stop()
		
		startCurrentAnimation: -> @entity.currentAnimation().start()
		
	signals: ->
		
		startedMoving: ->
			
			frameIndex = if @state.preserveFrameWhenMoving
				@entity.currentAnimation().currentFrameIndex
			else
				0
			
			@entity.setCurrentAnimationIndex @entity.visibilityIndex(), false
			@entity.currentAnimation().setCurrentFrameIndex frameIndex
		
		moving: (hypotenuse) ->
			
			###
			
			scale = Vector.div(
				hypotenuse
				Vector.hypotenuse hypotenuse
			)
			scale = if scale[0] then scale[0] else scale[1]
			
			@entity.currentAnimation().setFrameRateScaling(
				.25 + scale * .75
			)
			
			###
			
			@entity.setCurrentAnimationIndex @entity.visibilityIndex(), false
			
		stoppedMoving: ->
			
			@entity.setCurrentAnimationIndex 'initial', false
		
		directionChanged: (direction) ->
			
			for index, animation of @animationObjects
				animation.setCurrentDirection direction

	handler: ->
		
		renderer: (destination, position, clip) ->
			return unless @state.isVisible
			
			@entity.renderCurrentAnimation(
				position
				clip
				destination
				@state.alpha
			)
