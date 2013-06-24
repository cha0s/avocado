
Timing = require 'Timing'

EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'

module.exports = Ticker = class

	constructor: (frequency) ->
		EventEmitter.call this
		
		_private = PrivateScope.call @, Private, 'tickerScope'
		_private.frequency = frequency
		
	Mixin @::, EventEmitter
	
	elapsedSinceLast: -> throw new Error(
		'Ticker::elapsedSinceLast() is a pure virtual function!'
	)
	
	frequency: ->
	
		_private = @tickerScope Private
		_private.frequency
		
	reset: ->
		
		_private = @tickerScope Private
		_private.reset()
	
	setFrequency: (frequency) ->
	
		_private = @tickerScope Private
		_private.frequency = frequency
	
	tick: ->
		
		_private = @tickerScope Private
		_private.tick() 
		
	Private = class
	
		constructor: ->

			@remainder = 0
		
		reset: -> @remainder = 0

		tick: ->
			return if @frequency is 0
			
			_public = @public()
			elapsed = _public.elapsedSinceLast()
			
			ticks = 0
			if (accumulated = (elapsed + @remainder)) >= @frequency
				ticks = Math.floor accumulated / @frequency
	
			@remainder = accumulated - ticks * @frequency
			
			_public.emit 'tick' for i in [0...ticks]
				
			return

Ticker.InBand = class extends Ticker
	
	elapsedSinceLast: -> Timing.TimingService.tickElapsed() * 1000
					
Ticker.OutOfBand = class extends Ticker					
	
	constructor: ->
		super
		
		PrivateScope.call @, Private, 'outOfBandTickerScope'
	
	elapsedSinceLast: ->
		
		_private = @outOfBandTickerScope Private
		_private.elapsedSinceLast()
	
	reset: ->
		super
		
		_private = @outOfBandTickerScope Private
		_private.reset()
	
	Private = class
		
		constructor: ->
			
			@last = Timing.TimingService.elapsed()
			
		elapsedSinceLast: ->
			
			elapsed = (Timing.TimingService.elapsed() - @last) * 1000
			@last = Timing.TimingService.elapsed()
			elapsed
		
		reset: -> @last = Timing.TimingService.elapsed()
