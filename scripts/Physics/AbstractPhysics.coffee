
Config = require 'Config'
Ticker = require 'Timing/Ticker'
Vector = require 'Extension/Vector'

module.exports = class AbstractPhysics
	
	constructor: (
		gravity
	) ->
		
		@_ticker = new Ticker.InBand()
		
		@_ticker.setFrequency 1000 / Config.Physics.Tps
		@_ticker.on 'tick', => @step()
		
		@_walls = []
		
	addFloor: ->
	
	addCylinder: (entity, radius, height = 1, mass = 1) ->
	
	addSphere: (entity, radius, mass = 1) ->
	
	removeBody: (body) ->
		
	setWalls: (size) ->
		
	tick: -> @_ticker.tick()
	
	@fromScalar: (k) -> Config.Physics.MetersToPixelsScale * k
	
	@fromVector: (vector) ->
		Vector.mul(
			vector
			[
				Config.Physics.MetersToPixelsScale
				-Config.Physics.MetersToPixelsScale
			]
		)
		
	@position: (body) ->
	
	@radius: (body) ->
	
	@setLayer: (body, layer) ->
	
	@setPosition: (body, position) ->

	@setSize: (body, size) ->

	@setVelocity: (body, velocity) ->

	@toScalar: (k) -> Config.Physics.PixelsToMetersScale * k
	
	@toVector: (vector) ->
		Vector.mul(
			vector
			[
				Config.Physics.PixelsToMetersScale
				-Config.Physics.PixelsToMetersScale
			]
		)

	@velocity: (body) ->
