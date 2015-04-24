
Rectangle = require './Rectangle'

describe 'Rectangle', ->

	it "can calculate intersections", ->

		expect(Rectangle.intersects [0, 0, 16, 16], [8, 8, 24, 24]).toBe true
		expect(Rectangle.intersects [0, 0, 16, 16], [16, 16, 32, 32]).toBe false

		expect(Rectangle.isTouching [0, 0, 16, 16], [0, 0]).toBe true
		expect(Rectangle.isTouching [0, 0, 16, 16], [16, 16]).toBe false

		expect(Rectangle.intersection [0, 0, 16, 16], [8, 8, 24, 24]).toEqual [8, 8, 8, 8]

		expect(Rectangle.united [0, 0, 4, 4], [4, 4, 8, 8]).toEqual [0, 0, 12, 12]

	it "can compose and decompose", ->

		rectangle = Rectangle.compose [0, 0], [16, 16]

		expect(Rectangle.equals rectangle, [0, 0, 16, 16]).toBe true

		expect(Rectangle.position rectangle).toEqual [0, 0]
		expect(Rectangle.size rectangle).toEqual [16, 16]

	it "can make a deep copy", ->

		rectangle = [0, 0, 16, 16]
		rectangle2 = Rectangle.copy rectangle

		expect(Rectangle.equals rectangle, rectangle2).toBe true

		rectangle[0] = 6

		expect(Rectangle.equals rectangle, rectangle2).toBe false

	it "can convert to an object", ->

		rectangle = [0, 0, 16, 16]

		expect(Rectangle.toObject rectangle).toEqual(
			x: 0, y: 0, width: 16, height: 16
		)

		expect(Rectangle.toObject rectangle, true).toEqual(
			x: 0, y: 0, w: 16, h: 16
		)

	it "can translate by vector", ->

		expect(Rectangle.translated [0, 0, 16, 16], [8, 8]).toEqual [8, 8, 16, 16]

	it "can check for null", ->

		expect(Rectangle.isNull null).toBe true
		expect(Rectangle.isNull 3).toBe true
		expect(Rectangle.isNull [1]).toBe true
		expect(Rectangle.isNull [1, 1]).toBe true
		expect(Rectangle.isNull [1, 1, 1]).toBe true
		expect(Rectangle.isNull [1, 1, 1, 1, 1]).toBe true
		expect(Rectangle.isNull [0, 0, 1, 1]).toBe false
		expect(Rectangle.isNull [0, 0, 1, 0]).toBe true

	it "can do mathematical operations", ->

		expect(Rectangle.round [3.14, 4.70, 5.32, 1.8]).toEqual [3, 5, 5, 2]
		expect(Rectangle.floor [3.14, 4.70, 5.32, 1.8]).toEqual [3, 4, 5, 1]
