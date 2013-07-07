
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Property = require 'Mixin/Property'
Ticker = require 'Timing/Ticker'

module.exports = Animation = (
	indexName = 'index'
) ->

	_indexCount = "#{indexName}Count"
	_indexRate = "#{indexName}Rate"
	
	class
		
		mixins = [
			Property 'async', true
			IndexProperty = Property 'index', 0
			Property _indexCount, 0
			Property _indexRate, 100
		]
		
		constructor: ->
			EventEmitter.call this
			mixin.call this for mixin in mixins
			
			PrivateScope.call @, Private, 'timedIndexScope'
			
		Mixin @::, EventEmitter
		Mixin.apply null, [@::].concat mixins
		
		forwardCallToPrivate = (call) => PrivateScope.forwardCall(
			@::, call, (-> Private), 'timedIndexScope'
		)
		
		forwardCallToPrivate 'setIndex'
		
		forwardCallToPrivate 'start'
	
		forwardCallToPrivate 'stop'
	
		forwardCallToPrivate 'tick'
					
		Private = class
			
			constructor: (_public) ->
				
				@interval = null
				@ticker = null
				
			_tick: ->
				
				_public = @public()
				
				index = _public.index() + 1
				_public.setIndex Math.floor index % _public[_indexCount]()
				_public.emit 'rolledOver' if index >= _public[_indexCount]()
				
			setIndex: (index, reset = true) ->
				
				_public = @public()
				
				IndexProperty::setIndex.call(
					_public
					index % _public[_indexCount]()
				)
				
				@ticker.reset() if reset
			
			start: ->
				return if @interval?
				
				_public = @public()
				
				if _public.async()
					
					type = 'OutOfBand'
					@interval = setInterval (=> _public.tick()), 10
					
				else
					
					type = 'InBand'
					@interval = true
		
				@ticker = new Ticker[type]()
				@ticker.setFrequency _public[_indexRate]()
				
				@ticker.on 'tick', @_tick, @
	
			stop: ->
				return unless @interval?
				
				clearInterval @interval if @interval isnt true
				@interval = null
				
				@ticker.off 'tick'
				@ticker = null
				
			tick: -> @ticker?.tick()
