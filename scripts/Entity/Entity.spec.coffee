
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
			
		it "can specify a trait dependency tree", (done) ->

			entity = new Entity()
			entity.extendTraits([
				type: 'Dependency2'
			]).then ->
				
				expect(entity.foo).toBeDefined()
				
				done()
			
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
				).done()
			).not.toThrow()

		it "calls resetTrait() for all traits every time traits are extended", (done) ->
			
			Existence = require 'Entity/Traits/Existence'
			Test = require 'Entity/Traits/Test'
			Test2 = require 'Entity/Traits/Test2'
			
			originalExistenceReset = Existence::resetTrait
			originalTestReset = Test::resetTrait
			originalTest2Reset = Test2::resetTrait
			
			existenceReset = Existence::resetTrait = jasmine.createSpy()
			testReset = Test::resetTrait = jasmine.createSpy()
			test2Reset = Test2::resetTrait = jasmine.createSpy()
			
			entity = new Entity()
			entity.extendTraits([
				type: 'Test'
			,
				type: 'Test2'
			]).then ->
				
				expect(existenceReset.calls.length).toEqual 2
				expect(testReset.calls.length).toEqual 1
				expect(test2Reset.calls.length).toEqual 1
				
				Existence::resetTrait = originalExistenceReset
				Test::resetTrait = originalTestReset
				Test2::resetTrait = originalTest2Reset
				
				done()

		it "undefined state defaults should throw an exception as early as possible", ->
			
			StateDefaults = require 'Entity/Traits/StateDefaults'
			
			expect(->
				(new Entity()).fromObject(
					traits: [
						type: 'StateDefaults'
					]
				).done()
			).toThrow()
