
Entity = require 'Entity/Entity'
Room = require 'Environment/2D/Room'

describe 'Room', ->
	
	room = null

	it "can instantiate", (done) ->
		
		(room = new Room()).fromObject(
			size: [30, 20]
		).done ->
			
			expect(room.size()).toEqual [30, 20]
			expect(room.height()).toBe 20
			expect(room.width()).toBe 30
			
			# NULL tileIndices...
			secondRoom = new Room()
			
			secondRoom.fromObject(room.toJSON()).then(->
				for key in ['size', 'width', 'height']
					expect(room[key]()).toEqual secondRoom[key]()
			).done -> done()

	it "can resize", (done) ->
	
		(room = new Room()).fromObject(
			size: [30, 20]
		).done ->
		
			for i in [0...room.layerCount()]
				expect(room.layer(i).size()).toEqual [30, 20]
	
			room.setSize [10, 20]
			
			for i in [0...room.layerCount()]
				expect(room.layer(i).size()).toEqual [10, 20]
				
			done()

	it "can manage entities", ->
	
		room = new Room()
		expect(room.entityCount()).toBe 0
		
		entity = new Entity()
		room.addEntity entity 
		expect(room.entityCount()).toBe 1
		
		room.removeEntity entity
		expect(room.entityCount()).toBe 0

	it "can locate entities", ->
	
		room = new Room()
		
		positions = [
			[0, 0]
			[0, 10]
			[0, 20]
		]
		
		for position in positions
			entity = new Entity()
			entity.extendTraits [
				type: 'Existence'
				state: position: position
			]
			room.addEntity entity
		
		expect(room.entitiesNearPosition([0, 0], 9.9).length).toBe 1
		expect(room.entitiesNearPosition([0, 10], 10).length).toBe 3
		expect(room.entitiesNearPosition([30, 30], 15).length).toBe 0
		
	it "can chain calls from addEntity", ->
	
		room = new Room()
		entity = new Entity()
		 
		expect(room.addEntity entity).toBe entity
