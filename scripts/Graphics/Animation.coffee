# Animations control animating images.

CoreService = require('Core').CoreService
DisplayCommand = require 'Graphics/DisplayCommand'
EventEmitter = require 'Utility/EventEmitter'
Image = require('Graphics').Image
Mixin = require 'Utility/Mixin'
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Ticker = require 'Timing/Ticker'
Vector = require 'Extension/Vector'

module.exports = Animation = class
	
	constructor: ->
	
		Mixin this, EventEmitter
		
		# The image to animate.
		@image_ = new Image()
		
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
		
		Image.load(O.imageUri).then (image) =>
			
			# Set and break up the image into frames.
			@setImage image, O.frameSize
			
			this
		
	@load: (uri) ->
		
		CoreService.readJsonResource(uri).then (O) ->
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
	
	start: (asynchronous = true) ->
		return if @interval_ isnt null
		
		@frameTicker_.reset()
		
		if asynchronous
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
		alpha
		mode
		clip = [0, 0, 0, 0]
		index
	) ->
		return if @frameCount_ is 0
		
		if Rectangle.isNull clip
			clip[2] = @frameSize_[0]
			clip[3] = @frameSize_[1]
		
		rect = Rectangle.compose(
			Vector.add(
				@framePosition index
				Rectangle.position clip
			)
			Rectangle.size clip
		)
		
		@image_.render(
			position
			destination
			alpha
			mode
			rect
		)
	
	toJSON: ->
		
		@uri ?= ''
		
		image: @image_.uri() if @image_.uri() isnt @uri.replace '.animation.json', '.png'
		directionCount: @directionCount_
		frameRate: @frameRate_
		frameCount: @frameCount_
		frameSize: @frameSize_

module.exports.DisplayCommand = class extends DisplayCommand
	
	constructor: (
		list
		@animation_
		rectangle = [0, 0, 0, 0]
	) ->
		
		rectangle = Rectangle.compose(
			Rectangle.position rectangle
			@animation_.frameSize()
		) unless rectangle[2] and rectangle[3]
		
		super list, rectangle
		
		@animation_.on 'frameChanged.AnimationDisplayCommand', => @markAsDirty()
		
	render: (position, clip, destination) ->
		
		@animation_.render(
			position
			destination
			255
			Image.DrawMode_Blend
			clip
		)

