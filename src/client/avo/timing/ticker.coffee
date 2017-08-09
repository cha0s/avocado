
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

module.exports = Mixin.toClass [

  EventEmitter
  Property 'frequency', default: 0

], class Ticker

  constructor: (frequency = 0) ->

    @_remainder = 0
    @setFrequency frequency

  remaining: -> 1 - @_remainder / @frequency()

  reset: -> @_remainder = 0

  tick: (elapsed) ->

    return if (frequency = @frequency()) is 0

    ticks = 0

    @_remainder += elapsed
    if @_remainder >= frequency
      ticks = Math.floor @_remainder / frequency
      @_remainder -= ticks * frequency

    @emit 'tick', frequency for i in [0...ticks]

    return

module.exports.OutOfBand = class TickerOutOfBand extends Ticker

  constructor: ->
    super

    @_last = Date.now()

  elapsedSinceLast: ->

    now = Date.now()
    elapsed = now - @_last
    @_last = now
    elapsed

  reset: ->
    super

    @_last = Date.now()
