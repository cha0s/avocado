
Core = require 'Core'
Graphics = require 'Graphics'

_ = require 'Utility/underscore'
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Q = require 'Utility/Q'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
String = require 'Extension/String'
Ticker = require 'Timing/Ticker'
TimedIndex = require 'Mixin/TimedIndex'
Vector = require 'Extension/Vector'
VectorMixin = require 'Mixin/Vector'

module.exports = Animation = class Animation
	
	@load: (uri) ->
		Core.CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			(new Animation()).fromObject O
	
	mixins = [
		EventEmitter
		Property 'alpha', 1
		Property 'blendMode', Graphics.GraphicsService.BlendMode_Blend
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
		@_sprite = new Graphics.Sprite()
		@_ticker = null
		
		@on 'alphaChanged', => @_sprite.setAlpha @alpha()
		@on 'imageChanged', => @_sprite.setSource @image()
		@on 'positionChanged', => @_sprite.setPosition @position()
		@on 'blendModeChanged', => @_sprite.setBlendMode @blendMode()
#		@on 'scaleChanged', => @_sprite.setScale @scale()
		@on(
			[
				'directionChanged'
				'frameSizeChanged'
				'imageChanged'
				'indexChanged'
			]
			=> @_sprite.setSourceRectangle @sourceRectangle()
		)
	
	Mixin.apply null, [@::].concat mixins
	
	fromObject: (O) ->
		
		O.imageUri ?= O.uri.replace '.animation.json', '.png'
		
		for property in [
			'directionCount', 'frameCount', 'frameRate', 'frameSize', 'uri'
		]
			@[String.setterName property] O[property] if O[property]?
		
		Graphics.Image.load(O.imageUri).then (image) =>
			
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
	
	toJSON: ->
		
		defaultImageUri = @uri().replace '.animation.json', '.png'
		imageUri = @image().uri() if @image().uri() isnt defaultImageUri
		
		directionCount: @directionCount()
		frameRate: @frameRate()
		frameCount: @frameCount()
		frameSize: @frameSize()
		imageUri: imageUri
