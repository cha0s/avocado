
Behavior = require './index'

describe 'Behavior', ->

	describe 'conditions', ->

		it "can do binary compares", ->

			condition = new Behavior.Condition()
			condition.fromObject

				operator: '>'
				operands: [
					l: 500
				,
					l: 420
				]

			expect(condition.get()).toBe true

			condition.setOperator '<'
			expect(condition.get()).toBe false

			condition.setOperator '<='
			expect(condition.get()).toBe false

			condition.setOperator '>='
			expect(condition.get()).toBe true

			condition.setOperator 'is'
			expect(condition.get()).toBe false

			condition.setOperator 'isnt'
			expect(condition.get()).toBe true

		it "can do varnary compares", ->

			condition = new Behavior.Condition()
			condition.fromObject

				operator: 'and'
				operands: [
					l: true
				,
					l: true
				,
					l: false
				]

			expect(condition.get()).toBe false

			condition.setOperator 'or'
			expect(condition.get()).toBe true

			condition.setOperand 2, Behavior.instantiate l: true

			expect(condition.get()).toBe true

			condition.setOperator 'and'
			expect(condition.get()).toBe true

			for i in [0...3]
				condition.setOperand i, Behavior.instantiate l: false

			expect(condition.get()).toBe false

			condition.setOperator 'or'
			expect(condition.get()).toBe false
