
AvoImage = require 'avo/graphics/image'
Promise = require 'vendor/bluebird'
Tileset = require './tileset'

describe 'Tileset', ->

  image = null
  tileset = null

  beforeEach ->

    tileset = new Tileset()

  it "can chop up a tileset image into tiles", (done) ->

    tileset.fromObject(
      tileSize: [16, 16]
      image: new AvoImage [256, 256]
    ).then ->

      expect(tileset.tileCount()).toBe 256
      expect(tileset.tiles()).toEqual [16, 16]
      expect(tileset.tileBox 18).toEqual [32, 16, 16, 16]

      done()

  it "can be invalid", (done) ->

    expect(tileset.isValid()).toBe false

    tileset.fromObject(
      tileSize: [16, 16]
      image: new AvoImage()
    ).then ->

      expect(tileset.isValid()).toBe false

      tileset.fromObject(
        tileSize: [16, 16]
        image: new AvoImage [256, 256]
      ).then ->

        expect(tileset.isValid()).toBe true

        done()
