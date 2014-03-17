
ArrayExt = require '../../../Extension/Array'
FunctionExt = require '../../../Extension/Function'
Promise = require '../../../Utility/bluebird'

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
		
		Promise.resolve this
	
	evaluate: (variables) ->
		
		args = [variables].concat @condition
		
		unless FunctionExt.fastApply Evaluators.Condition, args
			return false
		
		Rule.Evaluate action, variables for action in @actions
			
		return true

Rule.Evaluate = (E, variables) ->
	
	[key] = Object.keys E
	
	args = [variables]
	ArrayExt.fastArrayPush args, E[key]
	
	FunctionExt.fastApply Evaluators[key], args
