
Environment = require 'avo/environment/2D'
Room = require 'avo/environment/2D/room'

describe 'Environment', ->

  room = null

  it "can instantiate", (done) ->

    O = rooms: [
      size: [10, 20]
    ,
      size: [20, 30]
    ]

    (new Environment()).fromObject(O).then (environment) ->

      expect(environment.roomCount()).toBe 2

      done()

  # it "defaults the name to the URI, unless a name is set", ->

  #   environment = new Environment()

  #   environment.setUri 'test'
  #   expect(environment.name()).toBe 'test'

  #   environment.setName 'foobar'
  #   expect(environment.name()).toBe 'foobar'
