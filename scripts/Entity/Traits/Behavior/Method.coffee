
ArrayExt = require 'Extension/Array'
FunctionExt = require 'Extension/Function'

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
		FunctionExt.fastApply O, args, holder
	
	while step < selector.length
		O = O[selector[step++]]
		holder = O = invoke()
		
	invoke()

exports.EvaluateManually = (variables, Method) ->
	FunctionExt.fastApply exports.Evaluate, [variables].concat Method

Evaluators = Method: exports.Evaluate
for elementName in ['Value']
	Element = require "Entity/Traits/Behavior/#{elementName}"
	Evaluators[elementName] = Element.Evaluate

Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	return E unless evaluate = Evaluators[key]
	
	args = [variables]
	ArrayExt.fastPushArray args, E[key]
	
	FunctionExt.fastApply evaluate, args
