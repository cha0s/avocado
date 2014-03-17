
Timing = require 'Timing'

_ = require 'Utility/underscore'
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
Property = require 'Mixin/Property'
Promise = require 'Utility/bluebird'
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
	
	constructor: (
		@_object, @_key
		{frequency, location, magnitude, median, modulators}
	) ->
		
		@_median = median
		
		mixin.call this for mixin in mixins
		
		@on 'magnitudeChanged', => @_magnitude2 = @magnitude() * 2
		
		@setFrequency frequency
		@setLocation location ? 0
		@setMagnitude magnitude
		
		@_min = @_median - magnitude if @_median?
		
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
				
		@_modulators = for modulator in modulators
		
			if _.isObject modulator
				
				if modulator.f?
					
					modulatorFunction(modulator.f) modulator
					
				else
				
					[key] = Object.keys modulator
					modulatorFunction(key) modulator[key]
			
			else
				
				modulatorFunction(modulator)()
			
		@_setKey = String.setterName @_key
		
		@_transitions = []
	
	Mixin.apply null, [@::].concat mixins
		
	tick: (elapsed) ->
		
		transition.tick() for transition in @_transitions
		
		frequency = @frequency()
		location = @location()
		
		location += elapsed
		if location > frequency
			location -= frequency
			
		@setLocation location
		
		min = if @_median?
			@_min
		else
			@_object[@_key]()
		
		value = _.reduce(
			@_modulators
			(l, r) -> l + r location / frequency
			0
		) / @_modulators.length
		
		@_object[@_setKey] min + value * @_magnitude2
		
	transition: ->
		
		transition = Transition.InBand::transition.apply @, arguments
		
		@_transitions.push transition
		
		transition.promise.then =>
			
			@_transitions.splice(
				@_transitions.indexOf transition
				1
			)
			
		transition

LfoResult = class

	constructor: (object, properties, @_duration = 0) ->
		
		@_deferred = null
		@_elapsed = 0
		@_isRunning = false
		@_object = {}
		@_properties = {}
		
		@start()
		
		@_duration /= 1000
		
		if @_duration > 0
			@_deferred = Promise.defer()
			@promise = @_deferred.promise.cancellable().catch(
				Promise.CancellationError, (error) =>

					@stop()
					Promise.reject error
					
			)
		
		for key, spec of properties
			@_properties[key] = new ModulatedProperty object, key, spec
	
	property: (key) -> @_properties[key]
		
	start: ->
		
		@_elapsed = 0
		@_isRunning = true
	
	stop: -> @_isRunning = false
	
	tick: ->
		return unless @_isRunning
		
		elapsed = @elapsedSinceLast()
		
		finished = false
		
		if @_duration > 0
			
			if @_duration <= @_elapsed += elapsed
				
				finished = true
				
				elapsed = @_elapsed - @_duration
				@_elapsed = @_duration
		
		property.tick elapsed for key, property of @_properties
			
		if @_duration > 0
			
			@_deferred.progress [@_elapsed, @_duration]
			
			if finished
				@_deferred.resolve()
				@stop()
			
		return

module.exports = Lfo = class					

	LfoResultOutOfBand = class extends LfoResult
	
		elapsedSinceLast: ->
			
			elapsed = Timing.TimingService.elapsed() - @_last
			@_last = Timing.TimingService.elapsed()
			elapsed
			
		start: (result) ->
			super
			
			@_last = Timing.TimingService.elapsed()
			@_interval = setInterval(
				=> @tick()
				10
			)
		
		stop: ->
			super
			
			clearInterval @_interval
			
	lfo: (properties, duration) ->
		
		new LfoResultOutOfBand @, properties, duration

Lfo.OutOfBand = Lfo

Lfo.InBand = class					

	LfoResultInBand = class extends LfoResult
	
		elapsedSinceLast: -> Timing.TimingService.tickElapsed()
	
	lfo: (properties, duration) ->
		
		new LfoResultInBand @, properties, duration
