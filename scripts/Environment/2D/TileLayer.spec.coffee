
TileLayer = require 'Environment/2D/TileLayer'

describe 'TileLayer', ->
	
	tileLayer = null
	
	it "can instantiate", ->
	
		tileLayer = new TileLayer [30, 20]
		
		expect(tileLayer.size()).toEqual [30, 20]
		expect(tileLayer.height()).toBe 20
		expect(tileLayer.width()).toBe 30
		expect(tileLayer.area()).toBe 600
		
	it "can resize without scrambling the tile data", ->
	
		tileLayer = new TileLayer [30, 20]
		
		# Checkerboard pattern...
		for y in [0...20]
			for x in [0...30]
				xm = x % 2
				ym = y % 2
				tileLayer.setTileIndex(
					if (xm or ym) and not (xm and ym) then 0 else 1
					[x, y]
				)
		
		# Make sure the checkerboard is intact...
		tileLayer.resize [5, 5]
		for y in [0...5]
			for x in [0...5]
				xm = x % 2
				ym = y % 2
				index = if (xm or ym) and not (xm and ym) then 0 else 1
				expect(tileLayer.tileIndex [x, y]).toBe index

	it "can validate and calculate tile indices and matrices", ->
	
		tileLayer = new TileLayer [5, 5]
		
		expect(tileLayer.tileIsValid [-1, 0]).toBe false
		expect(tileLayer.tileIsValid [0, 0]).toBe true
		expect(tileLayer.tileIsValid [4, 4]).toBe true
		expect(tileLayer.tileIsValid [5, 4]).toBe false
		
		expect(tileLayer.calcTileIndex [-1, 0]).not.toBeDefined()
		expect(tileLayer.calcTileIndex [0, 0]).toBe 0
		expect(tileLayer.calcTileIndex [4, 4]).toBe 24
		expect(tileLayer.calcTileIndex [5, 4]).not.toBeDefined()
		
		expect(tileLayer.tileMatrix [2, 2], [0, 0]).toEqual [[0, 0], [0, 0]]
		
		tileLayer.setTileIndex 69, [0, 1]
		tileLayer.setTileIndex 69, [1, 0]
		
		expect(tileLayer.tileMatrix [2, 2], [0, 0]).toEqual [[0, 69], [69, 0]]
		
		tileLayer.setTileMatrix [[0, 420]], [0, 0]
		
		expect(tileLayer.tileMatrix [2, 2], [0, 0]).toEqual [[0, 420], [69, 0]]
		