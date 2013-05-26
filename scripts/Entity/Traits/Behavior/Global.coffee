
_ = require 'Utility/underscore'
Q = require 'Utility/Q'

module.exports =
	
	mixin: (O, M, B = O) ->
		for type in ['actions', 'values']
			list = M[type]()
			O[key] = _.bind meta.f ? meta, B for key, meta of list
			
		return
	
	actions: ->
	
		nop:
			name: 'Do nothing'
			renderer: -> 'do nothing'
			f: ->
		
		waitMs: (ms) ->
			deferred = Q.defer()
			setTimeout deferred.resolve, ms
			deferred.promise
		
	values: ->
	
		randomRange: (min, max = min) ->
			min + Math.floor Math.random() * (1 + max - min)
	

module.exports.mixin module.exports, module.exports
