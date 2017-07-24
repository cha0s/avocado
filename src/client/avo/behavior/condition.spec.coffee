
Behavior = require 'avo/behavior'
Condition = require './condition'

describe 'Behavior', ->

  describe 'conditions', ->

    it "can do binary compares", ->

      condition = new Condition()
      condition.fromObject

        operator: '>'
        operands: [
          literal: 500
        ,
          literal: 420
        ]

      expect(condition.check()).toBe true

      condition.setOperator '<'
      expect(condition.check()).toBe false

      condition.setOperator '<='
      expect(condition.check()).toBe false

      condition.setOperator '>='
      expect(condition.check()).toBe true

      condition.setOperator 'is'
      expect(condition.check()).toBe false

      condition.setOperator 'isnt'
      expect(condition.check()).toBe true

    it "can do varnary compares", ->

      condition = new Condition()
      condition.fromObject

        operator: 'and'
        operands: [
          literal: true
        ,
          literal: true
        ,
          literal: false
        ]

      expect(condition.check()).toBe false

      condition.setOperator 'or'
      expect(condition.check()).toBe true

      condition.setOperand 2, Behavior.instantiate literal: true

      expect(condition.check()).toBe true

      condition.setOperator 'and'
      expect(condition.check()).toBe true

      for i in [0...3]
        condition.setOperand i, Behavior.instantiate literal: false

      expect(condition.check()).toBe false

      condition.setOperator 'or'
      expect(condition.check()).toBe false
