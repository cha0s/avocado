
timing = require 'avo/timing'

Rectangle = require 'avo/extension/rectangle'
Trait = require './trait'
Vector = require 'avo/extension/vector'

module.exports = Corporeal = class extends Trait

	stateDefaults: ->
		
		direction: 0
		directionCount: 1
		immovable: false
		offset: [0, 0]
		position: [-10000, -10000]
		rotation: 0
		size: [0, 0]
		
	constructor: ->
		super
		
		@_zIndex = 0
		
	properties: ->
		
		direction: set: (direction) ->
			@state.direction = if direction < 0
				0
			else if direction > @entity.directionCount()
				@entity.directionCount() - 1
			else
				direction
		
		directionCount: {}
		immovable: {}
		offset: 
			set: (offset) -> @state.offset = Vector.copy offset
			eq: (l, r) -> Vector.equals l, r
		position:
			set: (position) -> @state.position = Vector.copy position
			eq: (l, r) -> Vector.equals l, r
		rotation: {}
		size:
			set: (size) -> @state.size = Vector.copy size
			eq: (l, r) -> Vector.equals l, r
			
	values: ->
		
		height: -> @state.size[1]
		
		offsetX: -> @state.offset[0]
		
		offsetY: -> @state.offset[1]
		
		rectangle: ->
				
			Rectangle.compose(
				Vector.sub(
					@state.position
					Vector.scale @state.size, .5
				)
				@state.size
			)
		
		width: -> @state.size[0]
		
		x: -> @state.position[0]
		
		y: -> @state.position[1]
		
		zIndex: -> @_zIndex
			
	actions: ->
		
		applyImpulse: (vector, force) ->
			return if @entity.immovable()
			
			moveInvocations = @entity.invoke(
				'moveRequest'
				vector, force
			)
			
			# If no one cared about movement, we'll just do naive movement.
			if moveInvocations.length is 0
				
				@entity.setPosition Vector.add(
					@entity.position()
					Vector.scale(
						vector
						timing.tickElapsed() * force
					)
				)
				
		setHeight: (height) -> @entity.setSize [@state.size[0], height]
			
		setOffsetX: (x) -> @entity.setOffset [x, @entity.offsetY()]
		
		setOffsetY: (y) -> @entity.setOffset [@entity.offsetX(), y]
		
		setWidth: (width) -> @entity.setSize [width, @state.size[1]]
			
		setX: (x) -> @entity.setPosition [x, @state.position[1]]
			
		setY: (y) -> @entity.setPosition [@state.position[0], y]
		
	signals: ->
		
		positionChanged: -> @entity.emit 'updateZIndex'
		
		traitsChanged: -> @entity.emit 'updateZIndex'
		
		updateZIndex: ->

			zIndexInvocations = @entity.invoke 'zIndex'
			
			# If no one cared about movement, we'll just use y.
			if zIndexInvocations.length is 0
				
				@_zIndex = @state.position[1]
				
			else
				
				# ???
				@_zIndex = zIndexInvocations[0]
