
Behavior = require 'avo/behavior'

describe 'Behavior', ->

  literal = null

  beforeEach -> literal = Behavior.instantiate literal: 69

  it "can access literals", ->

    expect(literal.get()).toBe 69

  it "can modify literals", ->

    literal.set 420
    expect(literal.get()).toBe 420
