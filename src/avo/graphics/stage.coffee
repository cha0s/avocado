
PIXI = require 'avo/vendor/pixi'

color = require './color'

module.exports = class Stage

	constructor: (backgroundColor) ->
		
		@_stage = new PIXI.Stage()
		
	addChild: (child) -> @_stage.addChild child
	
	renderWith: (renderer) -> renderer.render @_stage
		
	setBackgroundColor: (backgroundColor) ->
		
		@_stage.setBackgroundColor backgroundColor.toInteger()

	backgroundColor: ->
		
		color.fromInteger @_stage.backgroundColor
