
Environment = require 'Environment/2D/Environment'
Room = require 'Environment/2D/Room'

describe 'Environment', ->
	
	room = null

	it "can instantiate", (done) ->
	
		O =
			rooms: [
				(new Room [10, 20]).toJSON()
				(new Room [20, 30]).toJSON()
			]
		
		(new Environment()).fromObject(O).then (environment) ->
			
			expect(environment.roomCount()).toBe 2
			expect(environment.tileset().isValid()).toBe false
			
			done()

	it "defaults the name to the URI, unless a name is set", ->
	
		environment = new Environment()
		
		environment.setUri 'test'
		expect(environment.name()).toBe 'test'
		
		environment.setName 'foobar'
		expect(environment.name()).toBe 'foobar'
