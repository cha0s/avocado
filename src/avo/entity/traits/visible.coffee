
Container = require 'avo/graphics/container'

Trait = require './trait'

module.exports = class Visible extends Trait
	
	constructor: ->
		super
		
		@_localContainer = new Container()
	
	initialize: ->
		
		@entity.on 'traitsChanged', =>
			
			@_localContainer.removeAllChildren()
			
			@entity.emit 'addToLocalContainer', @_localContainer
			
	stateDefaults: ->
		
		isVisible: true
		alpha: 1
		scale: [1, 1]
		
	values: ->
		
		localContainer: -> @_localContainer 
		
		localRectangle: -> @_localContainer.localRectangle()
