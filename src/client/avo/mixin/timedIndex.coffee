
Ticker = require 'avo/timing/ticker'

EventEmitter = require './eventEmitter'
Mixin = require './index'
Property = require './property'

module.exports = (
  indexName = 'index'
) ->

  _indexCount = "#{indexName}Count"
  _indexRate = "#{indexName}Rate"

  Mixin.toClass [

    EventEmitter
    IndexProperty = Property 'index', default: 0
    Property _indexCount, default: 0
    Property _indexRate, default: 100

  ], class TimedIndex

    constructor: ->

      @_ticking = false

      @_ticker = new Ticker()
      @_ticker.setFrequency @[_indexRate]()
      @_ticker.on 'tick', @_tick, @

      @on 'indexRateChanged', (indexRate) -> @_ticker.setFrequency indexRate

    _tick: ->

      index = @index() + 1
      @setIndex Math.floor index % @[_indexCount]()
      @emit 'rolledOver' if index >= @[_indexCount]()

    setIndex: (index, reset = true) ->

      IndexProperty::setIndex.call(
        @
        index % @[_indexCount]()
      )

      @_ticker.reset() if reset

    start: -> @_ticking = true

    stop: -> @_ticking = false

    tick: (elapsed) -> @_ticker.tick  elapsed if @_ticking
