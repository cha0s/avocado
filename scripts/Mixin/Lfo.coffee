
Timing = require 'Timing'

_ = require 'Utility/underscore'
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Property = require 'Mixin/Property'
Q = require 'Utility/kew'
String = require 'Extension/String'
Ticker = require 'Timing/Ticker'
Transition = require 'Mixin/Transition'

Modulator =
	
	Flat: ->
		(location) -> .5
	
	Linear: ->
		(location) -> 2 * if location < .5 then location else 1 - location

	Random: ({variance}) ->
		
		variance ?= .4
		
		(location) ->
			
			Math.max 0, Math.min 1, Math.random() * (variance + variance) - variance

	Sine: ->
		(location) -> .5 * (1 + Math.sin location * Math.PI * 2)

ModulatedProperty = class
	
	mixins = [
		EventEmitter
		Property 'frequency', 0
		Property 'location', 0
		Property 'magnitude', 0
		Transition.InBand
	]
	
	constructor: (object, key, spec) ->
		
		mixin.call this for mixin in mixins
		PrivateScope.call(
			@
			_.bind Private, null, object, key, spec
			'modulatedPropertyScope'
		)
	
	Mixin.apply null, [@::].concat mixins
	
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'modulatedPropertyScope'
	)
	
	forwardCallToPrivate 'tick'
	
	forwardCallToPrivate 'transition'
	
	Private = class
	
		constructor: (
			@object, @key
			{frequency, location, magnitude, @median, modulators}
			_public
		) ->
			
			_public.on 'magnitudeChanged', =>
				@magnitude2 = _public.magnitude() * 2
			
			_public.setFrequency frequency
			_public.setLocation location ? 0
			_public.setMagnitude magnitude
			
			@min = @median - magnitude if @median?
			
			modulatorFunction = (modulator) ->
				
				if _.isString modulator
					
					if Modulator[modulator]?
						Modulator[modulator]
					else
						console.warn "Invalid modulator: #{modulator}"
						Modulator.Flat
				else
					
					if _.isFunction modulator
						modulator
					else
						console.warn "Invalid modulator: #{modulator}"
						Modulator.Flat
					
			
			@modulators = for modulator in modulators
			
				if _.isObject modulator
					
					if modulator.f?
						
						modulatorFunction(modulator.f) modulator
						
					else
					
						[key] = Object.keys modulator
						modulatorFunction(key) modulator[key]
				
				else
					
					modulatorFunction(modulator)()
				
			@setKey = String.setterName @key
			
			@transitions = []
			
		tick: (elapsed) ->
			
			_public = @public()
			
			transition.tick() for transition in @transitions
			
			frequency = _public.frequency()
			location = _public.location()
			
			location += elapsed
			if location > frequency
				location -= frequency
				
			_public.setLocation location
			
			min = if @median?
				@min
			else
				@object[@key]()
			
			value = _.reduce(
				@modulators
				(l, r) => l + r location / frequency
				0
			) / @modulators.length
			
			@object[@setKey] min + value * @magnitude2
			
		transition: ->
			
			_public = @public()
			
			transition = Transition.InBand::transition.apply _public, arguments
			
			@transitions.push transition
			
			transition.promise.then =>
				
				@transitions.splice(
					@transitions.indexOf transition
					1
				)
				
			transition
	
LfoResult = class
	
	constructor: (object, properties, duration) ->
		
		_private = PrivateScope.call this, Private, 'lfoResultScope'
		
		_private.construct object, properties, duration
		
		@start()
		
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'lfoResultScope'
	)
	
	forwardCallToPrivate 'property'
	
	forwardCallToPrivate 'start'
	
	forwardCallToPrivate 'stop'
	
	forwardCallToPrivate 'tick'
	
	Private = class
		
		constructor: ->
			
			@deferred = null
			@duration = 0
			@elapsed = 0
			@isRunning = false
			@object = {}
			@properties = {}
			
		construct: (object, properties, @duration = 0) ->
			
			_public = @public()
			
			@duration /= 1000
			
			if @duration > 0
				@deferred = Q.defer()
				_public.promise = @deferred.promise
			
			for key, spec of properties
				@properties[key] = new ModulatedProperty object, key, spec
		
		property: (key) -> @properties[key]
			
		start: ->
			
			@elapsed = 0
			@isRunning = true
		
		stop: -> @isRunning = false
		
		tick: ->
			return unless @isRunning
			
			_public = @public()
			
			elapsed = _public.elapsedSinceLast()
			
			finished = false
			
			if @duration > 0
				
				if @duration <= @elapsed += elapsed
					
					finished = true
					
					elapsed = @elapsed - @duration
					@elapsed = @duration
			
			property.tick elapsed for key, property of @properties
				
			if @duration > 0
				
				@deferred.notify [@elapsed, @duration]
				
				if finished
					@deferred.resolve()
					_public.stop()
				
			return

module.exports = Lfo = class					

	LfoResultOutOfBand = class extends LfoResult
	
		constructor: ->
			super
			
			PrivateScope.call @, Private, 'lfoResultOutOfBandScope'
		
		forwardCallToPrivate = (call) => PrivateScope.forwardCall(
			@::, call, (-> Private), 'lfoResultOutOfBandScope'
		)
		
		forwardCallToPrivate 'elapsedSinceLast'
		
		forwardCallToPrivate 'start'
		
		forwardCallToPrivate 'stop'
		
		tick: ->
		
		Private = class
			
			elapsedSinceLast: ->
				
				elapsed = Timing.TimingService.elapsed() - @last
				@last = Timing.TimingService.elapsed()
				elapsed
				
			start: (result) ->
				
				_public = @public()
				
				LfoResult::start.call _public
				
				@last = Timing.TimingService.elapsed()
				@interval = setInterval(
					-> LfoResult::tick.call _public
					10
				)
			
			stop: ->
			
				_public = @public()
				
				LfoResult::stop.call _public
				
				clearInterval @interval
			
	lfo: (properties, duration) ->
		
		new LfoResultOutOfBand @, properties, duration

Lfo.OutOfBand = Lfo

Lfo.InBand = class					

	LfoResultInBand = class extends LfoResult
	
		elapsedSinceLast: -> Timing.TimingService.tickElapsed()
	
	lfo: (properties, duration) ->
		
		new LfoResultInBand @, properties, duration
