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

###

exports.Render = ->

	output = ''
	
	return arguments[0].toUpperCase() if arguments[0] is 'or' or arguments[0] is 'and'
	
	output += Render arguments[1]
	output += ' '
	output += comparisons[arguments[0]].name.toLowerCase()
	output += ' '
	output += Render arguments[2]

###
