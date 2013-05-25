
Entity = require 'Entity/Entity'

describe 'Entity', ->
	
	it "can instantiate without explicitly specifying traits, and defaults will be provided", ->
		
		entity = new Entity()
		
		O = uri: undefined, traits: [ type: 'Existence' ]
		expect(entity.toJSON()).toEqual O
		expect(entity.hasTrait 'Existence').toBe true
		expect(entity.position()).toEqual [-10000, -10000]

	describe 'trait-based functionality', ->
		
		entity = null
		
		beforeEach (done) ->
			
			entity = new Entity()
			entity.extendTraits([type: 'Test']).then -> done()
			
		it "can reset traits", ->
			
			expect(entity.baz()).toBe 420
			
			entity.setBaz 69
			expect(entity.baz()).toBe 69
			
			entity.reset()
			expect(entity.baz()).toBe 420
							
		it "can remove traits", ->
			
			expect(entity.hasTrait 'Test').toBe true
			
			entity.removeTrait 'Test'
			expect(entity.hasTrait 'Test').toBe false
	
		it "can invoke hooks", ->
			
			results = entity.invoke 'testHook', 'testing'
			expect(results.length).toBe 1
			expect(results[0]).toBe 'HOOK: testing'
	
		it "can emit signals", ->
			
			expect(entity.foo()).toBe true
			
			entity.emit 'testSignal'
			expect(entity.foo()).toBe 69

		it "can set trait variables", ->
			
			expect(entity.blah()).not.toBeDefined()
			
			entity.setTraitVariables foo: 69
			expect(entity.blah()).not.toBeDefined()
			
			entity.setTraitVariables blah: 69
			expect(entity.blah()).toBe 69

	describe 'regressions', ->
	
		it "doesn't crash when calling then().done() on the promise returned from fromObject()", ->
			
			expect(->
				(new Entity()).fromObject(
					traits: [
						type: 'Existence'
						state:
							directionCount: 4
							size: [8, 8]				
					]
				).then().done()
			).not.toThrow()
