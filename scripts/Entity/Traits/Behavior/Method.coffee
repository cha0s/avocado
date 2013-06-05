
exports.Evaluate = (variables, selector, argLists = []) ->
	[variable, selector...] = selector.split ':'
	
	return undefined unless (O = variables[variable])?
	
	return O if selector.length is 0
	
	step = 0
	holder = O
	
	invoke = ->
		return O if 'function' isnt typeof O
		
		args = for arg in argLists[step - 1]
			Evaluate arg, variables
		O.apply holder, args
	
	while step < selector.length
		O = O[selector[step++]]
		holder = O = invoke()
		
	invoke()

exports.EvaluateManually = (variables, Method) ->
	exports.Evaluate.apply exports.Evaluate, [variables].concat Method

Evaluators = Method: exports.Evaluate
for elementName in ['Value']
	Element = require "Entity/Traits/Behavior/#{elementName}"
	Evaluators[elementName] = Element.Evaluate

Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	
	args = [variables]
	args.push.apply args, E[key]
	
	Evaluators[key].apply Evaluators[key], args
