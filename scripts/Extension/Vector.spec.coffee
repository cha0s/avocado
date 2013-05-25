
Vector = require 'Extension/Vector'

describe 'Vector', ->
	
	it "can do mathematical operations", ->
		
		expect(Vector.scale [.5, 1.5], 2).toEqual [1, 3]
		
		expect(Vector.add [1, 2], [1, 1]).toEqual [2, 3]
		
		expect(Vector.sub [9, 5], [5, 2]).toEqual [4, 3]
		
		expect(Vector.mul [3, 5], [5, 5]).toEqual [15, 25]
		
		expect(Vector.div [15, 5], [5, 5]).toEqual [3, 1]
		
		expect(Vector.mod [13, 6], [5, 5]).toEqual [3, 1]
		
		expect(Vector.cartesianDistance [0, 0], [1, 1]).toBe Math.sqrt 2
		
		expect(Vector.min [-10, 10], [0, 0]).toEqual [-10, 0]
		
		expect(Vector.max [-10, 10], [0, 0]).toEqual [0, 10]
		
		expect(Vector.clamp [-10, 10], [0, 0], [5, 5]).toEqual [0, 5]
		
		expect(Vector.round [3.14, 4.70]).toEqual [3, 5]
				
		expect(Vector.dot [2, 3], [4, 5]).toEqual 23
				
		expect(Vector.hypotenuse [5, 5], [6, 7]).toEqual [-0.4472135954999579, -0.8944271909999159]
				
		expect(Vector.hypotenuse [.5, .7]).toEqual [0.5812381937190965, 0.813733471206735]
				
		expect(Vector.abs [23, -5.20]).toEqual [23, 5.20]
				
		expect(Vector.floor [3.14, 4.70]).toEqual [3, 4]
				
		expect(Vector.area [3, 6]).toBe 18

	it "can deep copy", ->
		
		vector = [0, 0]
		vector2 = Vector.copy vector
		
		expect(Vector.equals vector, vector2).toBe true
		
		vector[0] = 1
		
		expect(Vector.equals vector, vector2).toBe false

	it "can test for 0 or NULL", ->
		
		expect(Vector.isZero [0, 0]).toBe true
		expect(Vector.isZero [1, 0]).toBe false
		
		expect(Vector.isNull [0, 1]).toBe true
		expect(Vector.isNull [1, 1]).toBe false

	it "can convert to/from directions", ->
		
		expect(Vector.toDirection4 [0, 1]).toBe 2
		expect(Vector.toDirection4 [1, 0]).toBe 1
		
		expect(Vector.toDirection8 [1, 1]).toBe 5
		expect(Vector.toDirection8 [1, 0]).toBe 1
		
		expect(Vector.toDirection [0, 1], 4).toBe 2
		
		for i in [0...8]
			vector = Vector.fromDirection i
			expect(i).toBe Vector.toDirection vector, 8

	it "can convert to object", ->
		
		expect(Vector.toObject [0, 16]).toEqual x: 0, y: 16
