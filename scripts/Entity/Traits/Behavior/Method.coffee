Evaluators = {}

exports.Evaluate = (variables, selector, argLists = []) ->
	[variable, selector...] = selector.split ':'
	
	return undefined unless (O = variables[variable])?
	
	return O if selector.length is 0
	
	step = 0
	oHolder = O
	
	invoke = ->
		
		return O if 'function' isnt typeof O
		
		args = for arg in argLists[step - 1]
			Evaluate arg, variables
		O.apply oHolder, args
	
	while step < selector.length
		
		O = O[selector[step++]]
		oHolder = O
		
		O = invoke()
		
	invoke()

###

exports.Render = (selector, args = []) ->

	[name, candidate] = Rule.splitSelector selector
	
	renderedCandidate = candidate.split(':').map (e) ->
		
		Rule.customRenderers['candidates'][e] ?= e
		
	renderedCandidate = renderedCandidate.join ' '
	
	if Rule.customRenderers['invocations'][name]?
		
		output = Rule.customRenderers['invocations'][name](renderedCandidate, args)
	
	else
	
		output = renderedCandidate + ' ' + name
		
		if args.length > 0
		
			output += '('
			
			argOutput = ''
			for arg in args
				argOutput += ', ' if '' isnt argOutput
				
				argOutput += Render arg
			output += argOutput
			
			output += ')'
		
	output 

###

Evaluators['Method'] = exports.Evaluate

for elementName in ['Value']
	Element = require "Entity/Traits/Behavior/#{elementName}"
	
	Evaluators[elementName] = Element.Evaluate

Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	
	args = [variables]
	args.push.apply args, E[key]
	
	Evaluators[key].apply Evaluators[key], args
