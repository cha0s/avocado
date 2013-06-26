
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
		property.call this for property in properties
		
		PrivateScope.call @, Private, 'animationScope'
		
	properties = [
		Property 'alpha', 1
		Property 'async', true
		Property 'blendMode', Graphics.GraphicsService.BlendMode_Blend
		DirectionProperty = Property 'direction', 0
		Property 'directionCount', 1
		Property 'frameCount', 0
		Property 'frameRate', 100
		Property 'frameSize', [0, 0]
		ImageProperty = Property 'image', null
		IndexProperty = Property 'index', 0
		VectorMixin 'position'
		Property 'scale', [1, 1]
		Property 'uri', ''
	]
	
	Mixin @::, EventEmitter
	Mixin.apply null, [@::].concat properties
	
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call
		-> Private
		'animationScope'
	)
	
	@load: (uri) ->
		Core.CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			(new Animation()).fromObject O
	
	fromObject: (O) ->
		
		O.imageUri ?= O.uri.replace '.animation.json', '.png'
		
		for property in [
			'directionCount', 'frameCount', 'frameRate', 'frameSize', 'uri'
		]
			@[String.setterName property] O[property] if O[property]?
		
		Graphics.Image.load(O.imageUri).then (image) =>
			
			@setImage image, O.frameSize
			
			this
			
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
		
	forwardCallToPrivate 'render'

	forwardCallToPrivate 'setDirection'
	
	forwardCallToPrivate 'setIndex'
	
	forwardCallToPrivate 'start'

	forwardCallToPrivate 'stop'

	forwardCallToPrivate 'tick'
				
	toJSON: ->
		
		defaultImageUri = @uri().replace '.animation.json', '.png'
		imageUri = @image().uri() if @image().uri() isnt defaultImageUri
		
		directionCount: @directionCount()
		frameRate: @frameRate()
		frameCount: @frameCount()
		frameSize: @frameSize()
		imageUri: imageUri
		
	Private = class
		
		constructor: (_public) ->
			
			@interval = null
			@sprite = new Graphics.Sprite()
			@ticker = null
			
			_public.on 'alphaChanged', => @sprite.setAlpha _public.alpha()
			_public.on 'imageChanged', => @sprite.setSource _public.image()
			_public.on 'positionChanged', => @sprite.setPosition _public.position()
			_public.on 'blendModeChanged', => @sprite.setBlendMode _public.blendMode()
			_public.on 'scaleChanged', => @sprite.setScale _public.scale()
			_public.on(
				[
					'directionChanged'
					'frameSizeChanged'
					'imageChanged'
					'indexChanged'
				]
				=> @sprite.setSourceRectangle @sourceRectangle()
			)
			
		animate: ->
			
			_public = @public()
			
			index = _public.index() + 1
			_public.setIndex Math.floor index % _public.frameCount()
			_public.emit 'rolledOver' if index >= _public.frameCount()
			
		clampDirection: (direction) ->
			
			_public = @public()
			
			return 0 if _public.directionCount() is 1
			
			direction = Math.min 7, Math.max direction, 0
			direction = {
				4: 1
				5: 1
				6: 3
				7: 3
			}[direction] if _public.directionCount() is 4 and direction > 3
			
			direction
		
		render: (
			destination
			index
		) ->
			
			_public = @public()
			
			return unless _public.frameCount() > 0
			return unless _public.image()?
			
			if (index ?= _public.index()) isnt _public.index()
				@sprite.setSourceRectangle @sourceRectangle index
				
			@sprite.renderTo destination
			
		setDirection: (direction) ->
			DirectionProperty::setDirection.call(
				@public()
				@clampDirection direction
			)
		
		setIndex: (index) ->
			
			_public = @public()
			
			IndexProperty::setIndex.call(
				_public
				index % _public.frameCount()
			)
		
		sourceRectangle: (index) ->
			
			_public = @public()
			
			Rectangle.compose(
				Vector.mul _public.frameSize(), [
					(index ? _public.index()) % _public.frameCount()
					_public.direction()
				]
				_public.frameSize()
			)
		
		start: ->
			return if @interval?
			
			_public = @public()
			
			if _public.async()
				
				type = 'OutOfBand'
				@interval = setInterval (=> _public.tick()), 10
				
			else
				
				type = 'InBand'
				@interval = true
	
			@ticker = new Ticker[type]()
			@ticker.setFrequency _public.frameRate()
			
			@ticker.on 'tick', @animate, @

		stop: ->
			return unless @interval?
			
			clearInterval @interval if @interval isnt true
			@interval = null
			
			@ticker.off 'tick'
			@ticker = null
			
		tick: -> @ticker?.tick()
