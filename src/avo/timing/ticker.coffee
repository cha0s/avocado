
timing = require 'avo/timing'

EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

class Ticker

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

module.exports = class TickerOutOfBand extends Ticker

	constructor: ->
		super

		@_last = timing.elapsed()

	elapsedSinceLast: ->

		elapsed = (timing.elapsed() - @_last) * 1000
		@_last = timing.elapsed()
		elapsed

	reset: ->
		super

		@_last = timing.elapsed()

module.exports.OutOfBand = module.exports

module.exports.InBand = class TickerInBand extends Ticker

	elapsedSinceLast: -> timing.tickElapsed() * 1000
