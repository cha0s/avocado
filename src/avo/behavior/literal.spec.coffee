
Behavior = require './index'

describe 'Behavior', ->

  literal = null

  beforeEach -> literal = Behavior.instantiate l: 69

  it "literals can be accessed", ->

  	expect(literal.get()).toBe 69

  it "literals can be modified", ->

  	literal.set 420
  	expect(literal.get()).toBe 420
