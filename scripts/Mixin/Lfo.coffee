
Timing = require 'Timing'

_ = require 'Utility/underscore'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Property = require 'Mixin/Property'
Q = require 'Utility/Q'
String = require 'Extension/String'
Ticker = require 'Timing/Ticker'

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

	constructor: (
		@object, @key
		{@frequency, location, magnitude, @median, modulators}
	) ->
		
		@setKey = String.setterName @key
		@location = location ? 0
		
		@min = @median - magnitude if @median?
		
		@magnitude = magnitude * 2
		
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
			
	tick: (elapsed) ->
		
		@location += elapsed
		if @location > @frequency
			@location -= @frequency
		
		min = if @median?
			@min
		else
			@object[@key]()
		
		value = _.reduce(
			@modulators
			(l, r) => l + r @location / @frequency
			0
		) / @modulators.length
		
		@object[@setKey] min + value * @magnitude

LfoResult = class
	
	constructor: (object, properties, duration) ->
		
		_private = PrivateScope.call this, Private, 'lfoResultScope'
		
		_private.construct object, properties, duration
		
		@start()
		
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'lfoResultScope'
	)
	
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
			
			@properties = for key, spec of properties
				
				new ModulatedProperty object, key, spec
			
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
			
			property.tick elapsed for property in @properties
				
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
