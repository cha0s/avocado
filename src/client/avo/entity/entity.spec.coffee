
Entity = require 'avo/entity'
Trait = require 'avo/entity/traits/trait'

describe 'Entity', ->

  it "can instantiate without explicitly specifying traits, and defaults will be provided", ->

    entity = new Entity()

    O = traits: [ type: 'existent' ]
    expect(entity.toJSON()).toEqual O
    expect(entity.is 'existent').toBe true

  # describe 'trait-based functionality', ->

  #   entity = null
  #   testTrait = null

  #   beforeEach ->

  #     entity = new Entity()
  #     entity.extendTraits [type: 'testing']

  #   it "can remove traits", ->

  #     expect(entity.is 'testing').toBe true

  #     entity.removeTrait 'testing'
  #     expect(entity.is 'testing').toBe false

  #   it "can invoke hooks", ->

  #     results = entity.invoke 'testHook', 'testing'
  #     expect(results.length).toBe 1
  #     expect(results[0]).toBe 'HOOK: testing'

  #   it "can emit signals", ->

  #     expect(entity.foo()).toBe true

  #     entity.emit 'testSignal'
  #     expect(entity.foo()).toBe 69

  #   it "can specify a trait dependency tree", ->

  #     entity = new Entity()
  #     entity.extendTraits [type: 'dependent']

  #     expect(entity.foo).toBeDefined()
