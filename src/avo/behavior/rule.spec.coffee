
Behavior = require './index'

describe 'Behavior', ->

  it "rules can be invoked", ->

  	blah = 69
  	context = foo: bar: -> blah = 420

  	rule = Behavior.instantiate

  		ru:

  			condition:

  				operator: 'and'
  				operands: [
  					l: true
  				,
  					l: false
  				]


  			actions: [

  				selector: 'foo:bar'
  				args: [
  					[]
  				]

  			]

  	rule.invoke context

  	expect(blah).toBe 69

  	rule.condition().setOperand 1, Behavior.instantiate l: true

  	rule.invoke context

  	expect(blah).toBe 420
