
Behavior = require './index'

describe 'Behavior', ->
	
	it "actions can be invoked", ->
		
		cv = 0
		context =
			test:
				get: -> cv
				set: (cv_) -> cv = cv_
		
		value = new Behavior.Value()
		value.fromObject
			
			selector: 'test:get'
			args: [
				[
				]
			]
			
		expect(value.get context).toBe 0
			
		action = new Behavior.Action()
		action.fromObject
			
			selector: 'test:set'
			args: [
				[
					l: 69
				]
			]
		
		action.invoke context
		expect(value.get context).toBe 69
