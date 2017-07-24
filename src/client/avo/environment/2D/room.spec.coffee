
Entity = require 'avo/entity'
Room = require './room'

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
