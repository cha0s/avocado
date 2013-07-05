
Timing = require 'Timing'

Mixin = require 'Mixin/Mixin'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = Existence = class extends Trait

	stateDefaults: ->
		
		isDestroyed: false
		direction: 0
		directionCount: 1
		name: 'Abstract'
		position: [-10000, -10000]
		secondsSeen: 0
		size: [0, 0]
		
	properties: ->
		
		isDestroyed: {}
		direction: set: (direction) ->
			@state.direction = if direction < 0
				0
			else if direction > @entity.directionCount()
				@entity.directionCount() - 1
			else
				direction
		
		directionCount: {}
		name: {}	
		position:
			set: (position) -> @state.position = Vector.copy position
			eq: (l, r) -> Vector.equals l, r
		size:
			set: (size) -> @state.size = Vector.copy size
			eq: (l, r) -> Vector.equals l, r
	
	values: ->
		
		height: -> @state.size[1]
	
		rectangle: ->
				
			Array.composeRect(
				Vector.scale(
					Vector.sub @state.position, @state.size
					.5
				)
				@state.size
			)
		
		width: -> @state.size[0]
		
		x: -> @entity.position[0]
		
		y: -> @state.position[1]
		
		secondsSeen: -> @state.secondsSeen

	actions: ->
		
		setHeight: (height) -> @entity.setSize [@state.size[0], height]
			
		setWidth: (width) -> @entity.setSize [width, @state.size[1]]
			
		setX: (x) -> @entity.setPosition [x, @state.position[1]]
			
		setY: (y) -> @entity.setPosition [@state.position[0], y]
			
		signal: ->
			@entity.emit.apply @entity, arguments
			
			increment: 1
	
	handler: ->
		
		ticker: ->
			
			@state.secondsSeen += Timing.TimingService.tickElapsed()
