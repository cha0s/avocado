
TileLayer = require 'avo/environment/2D/tileLayer'

describe 'TileLayer', ->

  tileLayer = null

  it "can instantiate", (done) ->

    tileLayer = new TileLayer [30, 20]

    expect(tileLayer.size()).toEqual [30, 20]
    expect(tileLayer.height()).toBe 20
    expect(tileLayer.width()).toBe 30
    expect(tileLayer.area()).toBe 600

    # NULL tileIndices...
    secondTileLayer = new TileLayer()
    secondTileLayer.fromObject(tileLayer.toJSON()).then(->
      expect(tileLayer).toEqual secondTileLayer
      secondTileLayer.setTileIndexAt [0, 0], 1
    ).then ->

      # Compressed tileIndices...
      thirdTileLayer = new TileLayer()
      thirdTileLayer.fromObject(secondTileLayer.toJSON()).then(->
        expect(secondTileLayer).toEqual thirdTileLayer
      ).then -> done()

  it "can resize without scrambling the tile data", ->

    tileLayer = new TileLayer [30, 20]

    # Checkerboard pattern...
    for y in [0...20]
      for x in [0...30]
        xm = x % 2
        ym = y % 2
        tileLayer.setTileIndexAt(
          [x, y]
          if (xm or ym) and not (xm and ym) then 0 else 1
        )

    # Make sure the checkerboard is intact...
    tileLayer.setSize [5, 5]
    for y in [0...5]
      for x in [0...5]
        xm = x % 2
        ym = y % 2
        index = if (xm or ym) and not (xm and ym) then 0 else 1
        expect(tileLayer.tileIndexAt [x, y]).toBe index

  # it "can validate and calculate tile indices and matrices", ->

  #   tileLayer = new TileLayer [5, 5]

  #   expect(tileLayer.tileIsValid [-1, 0]).toBe false
  #   expect(tileLayer.tileIsValid [0, 0]).toBe true
  #   expect(tileLayer.tileIsValid [4, 4]).toBe true
  #   expect(tileLayer.tileIsValid [5, 4]).toBe false

  #   expect(tileLayer.calcTileIndex [-1, 0]).not.toBeDefined()
  #   expect(tileLayer.calcTileIndex [0, 0]).toBe 0
  #   expect(tileLayer.calcTileIndex [4, 4]).toBe 24
  #   expect(tileLayer.calcTileIndex [5, 4]).not.toBeDefined()

  #   expect(tileLayer.tileMatrix [2, 2], [0, 0]).toEqual [[0, 0], [0, 0]]

  #   tileLayer.setTileIndex 69, [0, 1]
  #   tileLayer.setTileIndex 69, [1, 0]

  #   expect(tileLayer.tileMatrix [2, 2], [0, 0]).toEqual [[0, 69], [69, 0]]

  #   tileLayer.setTileMatrix [[0, 420]], [0, 0]

  #   expect(tileLayer.tileMatrix [2, 2], [0, 0]).toEqual [[0, 420], [69, 0]]

  # it "can positionally locate tiles", ->

  #   tileset = new Tileset()
  #   tileset.setTileSize [16, 16]

  #   tileLayer = new TileLayer [5, 5]
  #   tileLayer.setTileset tileset

  #   expect(tileLayer.tileIndexFromPosition [10, 18]).toEqual [0, 1]
  #   expect(tileLayer.tileIndexFromPosition [31, 40]).toEqual [1, 2]
