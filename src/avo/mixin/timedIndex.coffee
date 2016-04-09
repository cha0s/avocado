
EventEmitter = require './eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require './index'
Property = require './property'
Ticker = require 'avo/timing/ticker'

module.exports = TimedIndex = (
  indexName = 'index'
) ->

  _indexCount = "#{indexName}Count"
  _indexRate = "#{indexName}Rate"

  class

    mixins = [
      EventEmitter
      IndexProperty = Property 'index', default: 0
      Property _indexCount, default: 0
      Property _indexRate, default: 100
    ]

    constructor: ->

      mixin.call this for mixin in mixins

      @_ticking = false

      @_ticker = new Ticker()
      @_ticker.setFrequency @[_indexRate]()
      @_ticker.on 'tick', @_tick, @

      @on 'indexRateChanged', (indexRate) -> @_ticker.setFrequency indexRate

    FunctionExt.fastApply Mixin, [@::].concat mixins

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
