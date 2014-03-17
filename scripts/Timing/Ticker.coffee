
Timing = require 'Timing'

EventEmitter = require '../Mixin/EventEmitter'
FunctionExt = require '../Extension/Function'
Mixin = require '../Mixin/Mixin'
Property = require '../Mixin/Property'

module.exports = Ticker = class Ticker

	mixins = [
		EventEmitter
		Property 'frequency', 0
	]
	
	constructor: (frequency = 0) ->
		
		mixin.call this for mixin in mixins
		
		@_remainder = 0
		@setFrequency frequency
	
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	remaining: -> 1 - @_remainder / @frequency()
	
	reset: -> @_remainder = 0

	tick: ->
		
		return if (frequency = @frequency()) is 0
		elapsed = @elapsedSinceLast()
		
		ticks = 0
		
		@_remainder += elapsed
		if @_remainder >= frequency
			ticks = Math.floor @_remainder / frequency
			@_remainder -= ticks * frequency
		
		@emit 'tick' for i in [0...ticks]
			
		return

Ticker.InBand = class TickerInBand extends Ticker
	
	elapsedSinceLast: -> Timing.TimingService.tickElapsed() * 1000
					
Ticker.OutOfBand = class TickerOutOfBand extends Ticker					
	
	constructor: ->
		super
		
		@_last = Timing.TimingService.elapsed()
		
	elapsedSinceLast: ->
		
		elapsed = (Timing.TimingService.elapsed() - @_last) * 1000
		@_last = Timing.TimingService.elapsed()
		elapsed
	
	reset: ->
		super
		
		@_last = Timing.TimingService.elapsed()
