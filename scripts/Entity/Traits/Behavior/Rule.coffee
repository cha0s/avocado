
Q = require 'Utility/Q'

Evaluators = {}
for elementName in ['Condition', 'Method', 'Value']
	Element = require "Entity/Traits/Behavior/#{elementName}"
	Evaluators[elementName] = Element.Evaluate

module.exports = Rule = class
	
	constructor: ->
	
		@condition = []
		@actions = []
	
	fromObject: (O) ->
	
		@condition = O.C.concat()
		@actions = O.A.concat()
		
		Q.resolve this
	
	evaluate: (variables) ->
		
		args = [variables].concat @condition
		
		unless Evaluators.Condition.apply Evaluators.Condition, args
			return false
		
		Rule.Evaluate action, variables for action in @actions
			
		return true

Rule.Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	
	args = [variables]
	args.push.apply args, E[key]
	
	Evaluators[key].apply Evaluators[key], args