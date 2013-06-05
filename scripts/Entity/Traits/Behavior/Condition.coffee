
comparisons =

	'is':
		name: 'Is/Equals'
		f: (v, l, r) -> Evaluate(l, v) is Evaluate(r, v)
		
	'isnt':
		name: "Isn't/Doesn't equal"
		f: (v, l, r) -> Evaluate(l, v) isnt Evaluate(r, v)
		
	'>':
		name: 'Greater than'
		f: (v, l, r) -> Evaluate(l, v) > Evaluate(r, v)
		
	'>=':
		name: 'Greater than or equal to'
		f: (v, l, r) -> Evaluate(l, v) >= Evaluate(r, v)
		
	'<':
		name: 'Less than'
		f: (v, l, r) -> Evaluate(l, v) < Evaluate(r, v)
		
	'<=':
		name: 'Less than or equal to'
		f: (v, l, r) -> Evaluate(l, v) <= Evaluate(r, v)
		
	'or':
		name: 'Or'
		f: (v) ->
		
			result = false
			
			index = 1
			while not result and index < arguments.length
				result = result or Evaluate arguments[index], v
				index += 1
				
			result
		
	'and':
		name: 'And'
		f: (v) ->
			
			result = true
			
			index = 1
			while result and index < arguments.length
				result = result and Evaluate arguments[index], v
				index += 1
				
			result


exports.Evaluate = (variables, op) -> 
	
	args = []
	
	index = 2
	
	args.push arguments[index++] while index < arguments.length
	
	args.unshift variables
	
	c = comparisons[op].f
	c.apply c, args

exports.EvaluateManually = (variables, Condition) ->
	exports.Evaluate.apply exports.Evaluate, [variables].concat Condition

Evaluators = Condition: exports.Evaluate
for elementName in ['Method', 'Value']
	Element = require "Entity/Traits/Behavior/#{elementName}"
	Evaluators[elementName] = Element.Evaluate

Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	
	args = [variables]
	args.push.apply args, E[key]
	
	Evaluators[key].apply Evaluators[key], args
