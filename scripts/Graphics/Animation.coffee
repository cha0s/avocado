
Core = require 'Core'
Graphics = require 'Graphics'

_ = require 'Utility/underscore'
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Q = require 'Utility/Q'
PrivateScope = require 'Utility/PrivateScope'
Property = require 'Mixin/Property'
Rectangle = require 'Extension/Rectangle'
String = require 'Extension/String'
Ticker = require 'Timing/Ticker'
Vector = require 'Extension/Vector'
VectorMixin = require 'Mixin/Vector'

module.exports = Animation = class
	
	constructor: ->
		EventEmitter.call this
		
		PrivateScope.call @, Private, 'animationScope'
		
	Mixin @::, EventEmitter
		
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call
		-> Private
		'animationScope'
	) 
	
	forwardPropertyToPrivate = (property) => PrivateScope.forwardProperty(
		@::, property
		-> Private
		'animationScope'
	) 
	
	@load: (uri) ->
		Core.CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			(new Animation()).fromObject O
	
	forwardPropertyToPrivate 'alpha'
	
	forwardPropertyToPrivate 'blendMode'
	
	forwardPropertyToPrivate 'direction'

	forwardPropertyToPrivate 'directionCount'

	forwardPropertyToPrivate 'frameCount'

	forwardPropertyToPrivate 'frameRate'

	forwardPropertyToPrivate 'frameSize'
	
	forwardCallToPrivate 'fromObject'

	forwardPropertyToPrivate 'image'

	forwardPropertyToPrivate 'index'

	forwardPropertyToPrivate 'position'

	forwardCallToPrivate 'render'

	forwardPropertyToPrivate 'scale'
	
	forwardCallToPrivate 'start'

	forwardCallToPrivate 'stop'

	forwardCallToPrivate 'tick'

	forwardCallToPrivate 'toJSON'

	Private = class
		
		Properties = [
			Property 'alpha', 1
			Property 'blendMode', Graphics.GraphicsService.BlendMode_Blend
			DirectionProperty = Property 'direction', 0
			Property 'directionCount', 1
			Property 'frameCount', 0
			Property 'frameRate', 100
			Property 'frameSize', [0, 0]
			ImageProperty = Property 'image', null
			Property 'index', 0
			VectorMixin [0, 0], 'position'
			Property 'scale', [1, 1]
		]
		
		constructor: (_public) ->
			Property.call this for Property in Properties
			
			@emit = (name) -> _public.emit.apply _public, arguments
			
			@interval = null
			@sprite = new Graphics.Sprite()
			@ticker = null
			
			setSourceRectangle = =>
				@sprite.setSourceRectangle @sourceRectangle()
				
			_public.on 'directionChanged', setSourceRectangle
			_public.on 'frameSizeChanged', setSourceRectangle
			_public.on 'frameSizeChanged', setSourceRectangle
			_public.on 'imageChanged', => setSourceRectangle
			_public.on 'indexChanged', setSourceRectangle

			_public.on 'imageChanged', => @sprite.setSource @image()
			
			_public.on 'positionChanged', => @sprite.setPosition @position()
			
			_public.on 'alphaChanged', => @sprite.setAlpha @alpha()
			
			_public.on 'blendModeChanged', => @sprite.setBlendMode @blendMode()
			
			_public.on 'scaleChanged', => @sprite.setScale @scale()
			
		Mixin.apply null, [@::].concat Properties
			
		animate: ->
			index = @index() + 1
			@setIndex Math.floor index % @frameCount()
			@public().emit 'rolledOver' if index >= @frameCount()
			
		fromObject: (O) ->
			
			O.imageUri ?= O.uri.replace '.animation.json', '.png'
			
			for property in [
				'directionCount', 'frameCount', 'frameRate', 'frameSize'
			]
				@[String.setterName property] O[property] if O[property]?
			
			Graphics.Image.load(O.imageUri).then (image) =>
				
				@setImage image, O.frameSize
				
				@public()
				
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
			index = @index()
		) ->
			return unless @frameCount() > 0
			return unless @image()?
			
			if index isnt @index()
				@sprite.setSourceRectangle @sourceRectangle index
				
			@sprite.renderTo destination
		
		setDirection: (direction) ->
			DirectionProperty::setDirection.call(
				this
				@clampDirection direction
			)
		
		setImage: (
			image
			frameSize
		) ->
			ImageProperty::setImage.call this, image
			
			_public = @public()
			
			_public.emit 'imageChanged'
			
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
		
		sourceRectangle: (index = @index()) ->
			
			Rectangle.compose(
				Vector.mul @frameSize(), [
					Math.floor index % @frameCount()
					@direction()
				]
				@frameSize()
			)
		
		start: (async = true) ->
			return if @interval?
			
			if async
				
				type = 'OutOfBand'
				@interval = setInterval (=> @tick()), 10
				
			else
				
				type = 'InBand'
				@interval = true
	
			@ticker = new Ticker[type] @frameRate()
			@ticker.on 'tick', @animate, @

		stop: ->
			return unless @interval?
			
			clearInterval @interval if @interval isnt true
			@interval = null
			
			@ticker.off 'tick'
			@ticker = null
			
		tick: -> @ticker?.tick() if @interval is true
				
		toJSON: ->
			
			directionCount: @directionCount()
			frameRate: @frameRate()
			frameCount: @frameCount()
			frameSize: @frameSize()
			imageUri: @image().uri() if @image().uri() isnt (@uri ? '').replace '.animation.json', '.png'
