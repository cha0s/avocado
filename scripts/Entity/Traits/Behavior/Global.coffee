
_ = require '../../../Utility/underscore'

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
		
	values: ->
	
		randomRange: (min, max = min) ->
			min + Math.floor Math.random() * (1 + max - min)
			
		object: ->
			O = {}
			i = 0
			while arguments[i]
				O[arguments[i]] = arguments[i + 1]
				i += 2
			O
		
		array: ->
			A = []
			i = 0
			while arguments[i]
				A.push arguments[i]
				i += 1
			A
	
module.exports.mixin module.exports, module.exports
