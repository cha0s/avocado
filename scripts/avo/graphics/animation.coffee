
#Core = require 'avo/core'
#Graphics = require 'avo/graphics'

_ = require 'avo/vendor/underscore'
EventEmitter = require 'avo/mixin/eventEmitter'
fs = require 'avo/fs'
FunctionExt = require 'avo/extension/function'
Image = require 'avo/graphics/image'
Mixin = require 'avo/mixin'
Promise = require 'avo/vendor/bluebird'
Property = require 'avo/mixin/property'
Rectangle = require 'avo/extension/rectangle'
Sprite = require 'avo/graphics/sprite'
String = require 'avo/extension/string'
Ticker = require 'avo/timing/ticker'
TimedIndex = require 'avo/mixin/timedIndex'
Vector = require 'avo/extension/vector'
VectorMixin = require 'avo/mixin/vector'

module.exports = Animation = class Animation
	
	@load: (uri) ->
		fs.readJsonResource(uri).then (O) ->
			O.uri = uri
			(new Animation()).fromObject O
	
	mixins = [
		EventEmitter
		Property 'alpha', 1
#		Property 'blendMode', Graphics.GraphicsService.BlendMode_Blend
		DirectionProperty = Property 'direction', 0
		Property 'directionCount', 1
		Property 'frameSize', [0, 0]
		ImageProperty = Property 'image', null
		VectorMixin 'position'
		Property 'scale', [1, 1]
		TimedIndex 'frame'
		Property 'uri', ''
	]
	
	constructor: ->
		
		mixin.call @ for mixin in mixins
		
		@_interval = null
		@_sprite = null
		@_ticker = null
		
#		@on 'alphaChanged', => @_sprite.setAlpha @alpha()
		@on 'imageChanged', =>
			if @_sprite?
				@_sprite.setSource @image()
			else
				@_sprite = new Sprite @image()
			
		@on 'positionChanged', => @_sprite.setPosition @position()
#		@on 'blendModeChanged', => @_sprite.setBlendMode @blendMode()
#		@on 'scaleChanged', => @_sprite.setScale @scale()
		@on(
			[
				'directionChanged'
				'frameSizeChanged'
				'imageChanged'
				'indexChanged'
			]
			=>
				@_sprite.setSourceRectangle @sourceRectangle()
		)
	
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	fromObject: (O) ->
		
		O.imageUri ?= O.uri.replace '.animation.json', '.png'
		
		for property in [
			'directionCount', 'frameCount', 'frameRate', 'frameSize', 'uri'
		]
			@[String.setterName property] O[property] if O[property]?
		
		Image.load(O.imageUri).then (image) =>
			
			@setImage image, O.frameSize
			
			this
		
	addToStage: (stage) ->
		
		@_sprite.addToStage stage
			
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
