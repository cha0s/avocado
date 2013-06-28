
Timing = require 'Timing'

EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Property = require 'Mixin/Property'

module.exports = Ticker = class

	constructor: ->
		EventEmitter.call this
		property.call this for property in properties
		
		PrivateScope.call @, Private, 'tickerScope'
	
	Mixin @::, EventEmitter

	properties = [
		Property 'frequency', 0
	]
	Mixin.apply null, [@::].concat properties
	
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'tickerScope'
	)
	
	elapsedSinceLast: -> throw new Error(
		'Ticker::elapsedSinceLast() is a pure virtual function!'
	)
	
	forwardCallToPrivate 'remaining'
	
	forwardCallToPrivate 'reset'
	
	forwardCallToPrivate 'tick'
	
	Private = class
	
		constructor: -> @remainder = 0
		
		remaining: -> 1 - @remainder / @public().frequency()
		
		reset: -> @remainder = 0

		tick: ->
			
			_public = @public()
			
			return if (frequency = _public.frequency()) is 0
			elapsed = _public.elapsedSinceLast()
			
			ticks = 0
			
			@remainder += elapsed
			if @remainder >= frequency
				ticks = Math.floor @remainder / frequency
				@remainder -= ticks * frequency
			
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
		
		constructor: -> @last = Timing.TimingService.elapsed()
			
		elapsedSinceLast: ->
			
			elapsed = (Timing.TimingService.elapsed() - @last) * 1000
			@last = Timing.TimingService.elapsed()
			elapsed
		
		reset: -> @last = Timing.TimingService.elapsed()
