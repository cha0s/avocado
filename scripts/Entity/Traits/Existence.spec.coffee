
Entity = require '../Entity'

describe 'Existence', ->
	
	entity = null
	
	spy =
		positionChanged: ->
		sizeChanged: ->
		directionChanged: ->
	
	beforeEach ->
		
		entity = new Entity()
		
	it "has defaults", ->
		
		expect(entity.position()).toEqual [-10000, -10000]
		expect(entity.size()).toEqual [0, 0]
		expect(entity.directionCount()).toEqual 1
		expect(entity.direction()).toEqual 0
		
	it "can set positional information, and signals are emitted", ->
		
		spyOn spy, 'positionChanged'
		entity.on 'positionChanged', spy.positionChanged
		
		entity.setX 50
		expect(entity.position()).toEqual [50, -10000]
		
		entity.setY 20
		expect(entity.position()).toEqual [50, 20]
		
		entity.setPosition [50, 20]
		
		entity.setPosition [34, 56]
		expect(entity.position()).toEqual [34, 56]
		
		expect(spy.positionChanged.calls.length).toEqual 3
		
	it "can set size information, and signals are emitted", ->
		
		spyOn spy, 'sizeChanged'
		entity.on 'sizeChanged', spy.sizeChanged
		
		entity.setWidth 50
		expect(entity.size()).toEqual [50, 0]
		
		entity.setHeight 20
		expect(entity.size()).toEqual [50, 20]
		
		entity.setSize [50, 20]
		
		entity.setSize [34, 56]
		expect(entity.size()).toEqual [34, 56]
		
		expect(spy.sizeChanged.calls.length).toEqual 3
		
	it "can set directional information, and signals are emitted", ->
		
		spyOn spy, 'directionChanged'
		entity.on 'directionChanged', spy.directionChanged
		
		entity.setDirectionCount 4
		entity.setDirection 2
		expect(entity.direction()).toEqual 2

		entity.setDirection 2
		
		expect(spy.directionChanged.calls.length).toEqual 1
		
	it "emit arbitrary signals", ->
		
		spyOn spy, 'directionChanged'
		entity.on 'directionChanged', spy.directionChanged
		
		entity.signal 'directionChanged'
		
		expect(spy.directionChanged.calls.length).toEqual 1
		