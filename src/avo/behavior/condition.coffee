
Promise = require 'avo/vendor/bluebird'

Behavior = require './index'
BehaviorItem = require './behaviorItem'

module.exports = class Condition extends BehaviorItem

	constructor: ->
		
		@_operator = ''
		@_operands = []
		
	fromObject: (O) ->
		
		@_operator = O.operator

		Promise.allAsap(
			Behavior.instantiate operand for operand in O.operands
			(@_operands) => this
		)
	
	get: (context) ->
		
		switch @_operator
		
			when 'is'
			
				@_operands[0].get(context) is @_operands[1].get(context)
			
			when 'isnt'

				@_operands[0].get(context) isnt @_operands[1].get(context)
			
			when '>'

				@_operands[0].get(context) > @_operands[1].get(context)
			
			when '>='

				@_operands[0].get(context) >= @_operands[1].get(context)
			
			when '<'
				
				@_operands[0].get(context) < @_operands[1].get(context)
			
			when '<='

				@_operands[0].get(context) <= @_operands[1].get(context)
			
			when 'or'
				
				return true if @_operands.length is 0

				result = false
				
				index = 0
				while not result and index < @_operands.length
					result = result or !!@_operands[index].get context
					index += 1
					
				result
				
			when 'and'
		
				result = true
				
				index = 0
				while result and index < @_operands.length
					result = result and !!@_operands[index].get context
					index += 1
					
				result

	operandCount: -> @_operands.length
	
	operand: (index) -> @_operands[index]
	
	operands: -> @_operands
	
	operator: -> @_operator
	
	setOperand: (index, operand) -> @_operands[index] = operand
	
	setOperator: (operator) -> @_operator = operator
	
	toJSON: -> c:
		
		operator: @_operator
		operands: @_operands.map (operand) -> operand.toJSON()
