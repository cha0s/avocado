
Array = require 'Extension/Array'

describe 'Array', ->
	
	it "can select a random element", ->
		
		expect(Array.randomElement [0, 1, 2]).toBeLessThan 3
