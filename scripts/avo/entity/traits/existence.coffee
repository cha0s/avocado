
Timing = require 'avo/timing'

FunctionExt = require 'avo/extension/function'
Lfo = require 'avo/mixin/lfo'
Promise = require 'avo/vendor/bluebird'
Trait = require './trait'

module.exports = Existence = class extends Trait

	stateDefaults: ->
		
		isDestroyed: false
		name: 'Untitled'
		
	properties: ->
		
		isDestroyed: {}
		name: {}
	
	actions: ->
		
		lfo: (properties, duration, state) ->
			
			lfo = FunctionExt.fastApply Lfo.InBand::lfo, arguments, @entity
			
			state.setPromise lfo.promise
			state.setTicker -> lfo.tick()
			
		signal: -> FunctionExt.fastApply @entity.emit, arguments, @entity
	
		waitMs:
			
			f: (ms, state) ->
				
				deferred = Promise.defer()
				
				waited = 0
				
				state.setPromise deferred.promise
				state.setTicker ->
					
					waited += Timing.TimingService.tickElapsed() * 1000
					deferred.resolve() if waited >= ms
