# Animations control animating images.

Core = require 'Core'
Graphics = require 'Graphics'

EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Ticker = require 'Timing/Ticker'
Vector = require 'Extension/Vector'

module.exports = Animation = class
	
	constructor: ->
	
		Mixin this, EventEmitter
		
		# The image to animate.
		@image_ = new Graphics.Image()
		
		# The current frame index.
		@currentFrameIndex_ = 0
		
		# The current direction.
		@currentDirection_ = 0
		
		# The size (in frames) of the animation.
		@frameArea_ = [0, 0]
		
		# The rate at which the frames increment. Default to 10 FPS.
		@frameRate_ = 100
		@frameTicker_ = new Ticker @frameRate_
		
		# Total number of frames in this animation.
		@frameCount_ = 1
		
		# The size of each individual frame.
		@frameSize_ = [0, 0]
		
		# Total number of directions.
		@directionCount_ = 1
		
		# Whether the animation is paused.
		@paused_ = false
		
		# The handle for the recurring tick interval.
		@interval_ = null
		
		@frameRateScaling_ = 1
		
	fromObject: (O) ->
		
		@["#{i}_"] = O[i] for i of O
		
		# Try using the animation's URI as the starting pattern for an image
		# if a URI wasn't given.
		O.imageUri = O.uri.replace '.animation.json', '.png' if not O.imageUri?
		
		@frameTicker_ = new Ticker @frameRate_
		
		Graphics.Image.load(O.imageUri).then (image) =>
			
			# Set and break up the image into frames.
			@setImage image, O.frameSize
			
			this
		
	@load: (uri) ->
		
		Core.CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			animation = new Animation()
			animation.fromObject O
	
	# ***Internal***: Helper function to set the ticker frequency as the
	# scaled frame rate.
	setTickerFrequency: ->
		
		@frameTicker_.setFrequency @frameRate_ / @frameRateScaling_
	
	# Set the frame rate of the animation. 
	setFrameRate: (@frameRate_) -> @setTickerFrequency()
	
	# Set the scale of the frame rate.
	setFrameRateScaling: (@frameRateScaling_) -> @setTickerFrequency()
	
	# Set the image used for the animation.
	setImage: (
		@image_
		
		# If the frame size isn't explicitly given, then calculate the size of
		# one frame using the total number of frames and the total spritesheet
		# size. Width is calculated by dividing the total spritesheet width by
		# the number of frames, and the height is the height of the spritesheet
		# divided by the number of directions in the animation.
		@frameSize_ = Vector.div(
			@image_.size()
			[@frameCount_, @directionCount_]
		)
	) ->
		
		# Pre-calculate the total number of frames.
		@calculateFrameArea()
	
	# Map 8-direction or 4-direction to this animation's direction.
	mapDirection: (direction) ->
		
		return 0 if @directionCount_ is 1
		
		direction = Math.min 7, Math.max direction, 0
		direction = {
			4: 1
			5: 1
			6: 3
			7: 3
		}[direction] if @directionCount_ is 4 and direction > 3
		
		direction
	
	currentDirection: -> @currentDirection_
		
	setCurrentDirection: (direction) ->
		
		@currentDirection_ = @mapDirection direction
		
		@emit 'directionChanged'
	
	currentFrameIndex: -> @currentFrameIndex_
	
	setCurrentFrameIndex: (index) ->
		
		@currentFrameIndex_ = Math.min @frameCount_ - 1, Math.max index, 0
		
		@emit 'frameChanged'		
	
	# Calculate the area of the animation, in frames.
	calculateFrameArea: ->
		
		# Make sure the matrix changed before trying to allocate a new one.
		matrix = Vector.div @image_.size(), @frameSize_
		return if Vector.equals matrix, @frameArea_

		@frameArea_ = matrix
	
	# Get the position of one frame within the image.
	framePosition: (index = @currentFrameIndex_) ->

		Vector.mul @frameSize_, [
			Math.floor index % @frameArea_[0]
			@currentDirection_ + Math.floor(index / @frameArea_[0]) % @frameArea_[1]
		]
	
	frameSize: -> @frameSize_
	
	isPaused: -> @paused_ or @interval_ is null
	isRunning: -> not @paused_ and @interval_ isnt null
	
	pause: -> @paused_ = true
	unpause: -> @paused_ = false
	
	tick: ->
		
		return if @paused_
		
		if @frameCount_ is 0
			@emit 'rolledOver'
			return
			
		# Get the number of ticks (if any)
		ticks = 0
		if ticks = @frameTicker_.ticks()
			
			# If we got some, increment the current frame pointer by how
			# many we got, but clamp it to the number of frames.
			c = @currentFrameIndex_ + ticks

			# Clamped current index.
			@currentFrameIndex_ = Math.floor c % @frameCount_

			# If the animation rolled over, return TRUE.
			@emit 'frameChanged'
			@emit 'rolledOver' if c >= @frameCount_
	
	start: (async = true) ->
		return if @interval_ isnt null
		
		@frameTicker_ = new Ticker @frameRate_, async
		
		if async
			@interval_ = setInterval (=> @tick()), 10
		else
			@interval_ = true
		
	stop: ->
		return if @interval_ is null
		
		clearInterval @interval_ unless @interval_ is true
		@interval_ = null
		
	render: (
		position
		destination
		alpha = 1
		scale = [1, 1]
		mode = Graphics.GraphicsService.BlendMode_Blend
		index
	) ->
		return if @frameCount_ is 0
		
		sprite = new Graphics.Sprite()
		sprite.setSource @image_
		sprite.setPosition position
		sprite.setBlendMode mode
		sprite.setAlpha alpha
		sprite.setScale scale[0], scale[1]
		sprite.setSourceRectangle Rectangle.compose(
			@framePosition index
			@frameSize_
		)
		sprite.renderTo destination
	
	toJSON: ->
		
		@uri ?= ''
		
		image: @image_.uri() if @image_.uri() isnt @uri.replace '.animation.json', '.png'
		directionCount: @directionCount_
		frameRate: @frameRate_
		frameCount: @frameCount_
		frameSize: @frameSize_
