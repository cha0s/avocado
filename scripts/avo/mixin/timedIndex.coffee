
EventEmitter = require './eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require '.'
Property = require './property'
Ticker = require 'avo/timing/ticker'

module.exports = Animation = (
	indexName = 'index'
) ->

	_indexCount = "#{indexName}Count"
	_indexRate = "#{indexName}Rate"
	
	class
		
		mixins = [
			EventEmitter
			Property 'async', true
			IndexProperty = Property 'index', 0
			Property _indexCount, 0
			Property _indexRate, 100
		]
		
		constructor: ->
			
			mixin.call this for mixin in mixins
			
			@_interval = null
			@_ticker = null
			
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
		
		start: ->
			return if @_interval?
			
			if @async()
				
				type = 'OutOfBand'
				@_interval = setInterval (=> @tick()), 10
				
			else
				
				type = 'InBand'
				@_interval = true
	
			@_ticker = new Ticker[type]()
			@_ticker.setFrequency @[_indexRate]()
			
			@_ticker.on 'tick', @_tick, @

		stop: ->
			return unless @_interval?
			
			clearInterval @_interval if @_interval isnt true
			@_interval = null
			
			@_ticker.off 'tick'
			@_ticker = null
			
		tick: -> @_ticker?.tick()
