Evaluators = {}
#Renderers = {}

for elementName in ['Condition', 'Method', 'Value']
	Element = require "Entity/Traits/Behavior/#{elementName}"
	
	Evaluators[elementName] = Element.Evaluate
#	Renderers[elementName] = Element.Render

module.exports = Rule = class
	
	@variables = {}
	
	constructor: ->
	
		@variables = {}
		
		@condition = []
		@actions = []
	
	setVariables: (variables) ->
		
		for key, value of variables
			@variables[key] = value
	
	fromObject: (O) ->
	
		@condition = O.C.concat()
		@actions = O.A.concat()
	
	evaluate: ->
		
		allVariables = {}
		for source in [Rule.variables, @variables]
			allVariables[k] = v for k, v of source
		
		args = [allVariables]
		args.push.apply args, @condition
		
		unless Evaluators.Condition.apply Evaluators.Condition, args
			return false
		
		for action in @actions
			Rule.Evaluate action, allVariables
			
		return true

###

Rule.Render = (R) ->
	
	throw new Error 'Behavior.Render called on a useless object' unless R
	[key] = Object.keys R
	
	Renderers[key].apply Renderers[key], R[key]

###

Rule.Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	
	args = [variables]
	args.push.apply args, E[key]
	
	Evaluators[key].apply Evaluators[key], args
