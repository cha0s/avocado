
Promise = require 'avo/vendor/bluebird'

FunctionExt = require 'avo/extension/function'

Transition = require 'avo/mixin/transition'
Lfo = require 'avo/mixin/lfo'

Timing = require 'avo/timing'

Trait = require './trait'

module.exports = Existent = class extends Trait

  stateDefaults: ->

  	name: 'Untitled'

  properties: ->

  	name: {}

  actions: ->

  	destroy: -> @entity.emit 'destroyed'

  	lfo: (properties, duration, state) ->

  		lfo = FunctionExt.fastApply Lfo.InBand::lfo, arguments, @entity

  		state.setPromise lfo.promise
  		state.setTicker -> lfo.tick()

  	transition: (properties, duration, easing, state) ->

  		unless state?
  			state = easing
  			easing = null

  		transition = FunctionExt.fastApply(
  			Transition.InBand::transition
  			[properties, duration, easing]
  			@entity
  		)

  		state.setPromise transition.promise
  		state.setTicker -> transition.tick()

  	signal: -> FunctionExt.fastApply @entity.emit, arguments, @entity

  	waitMs:

  		f: (ms, state) ->

  			deferred = Promise.defer()

  			waited = 0

  			state.setPromise deferred.promise
  			state.setTicker ->

  				waited += Timing.TimingService.tickElapsed() * 1000
  				deferred.resolve() if waited >= ms
