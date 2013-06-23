
Timing = require 'Timing'

Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	stateDefaults: ->
		
		position: [-10000, -10000]
		
		size: [0, 0]
		
		directionCount: 1
		direction: 0
		
		secondsSeen: 0
		
		name: 'Abstract'
	
	resetTrait: ->
		
		# Set direction and force emit the event.
		@entity.setDirection @state.direction
		@entity.emit 'directionChanged', @state.direction
		
	values: ->
		
		x: -> @state.position[0]
		y: -> @state.position[1]
		position:
			result: 'Position'
			f: -> @state.position
		
		width: -> @state.size[0]
		height: -> @state.size[1]
		size: -> @state.size
		
		rectangle:
			result: 'Rectangle'
			name: 'Rectangle'
			renderer: (candidate, args) -> "#{candidate} rectangle"
			f: ->
				
				Array.composeRect(
					Vector.scale(
						Vector.sub @state.position, @state.size
						.5
					)
					@state.size
				)
		
		secondsSeen: -> @state.secondsSeen

		direction:
			
			result: 'Number'
			f: -> @state.direction
		
		directionCount: -> @state.directionCount
			
		name: -> @state.name
		
	actions: ->
		
		signal:
			name: 'Emit signal'
			argTypes: ['String']
			argNames: ['Signal']
			renderer: (candidate, args) ->
				'emit ' + candidate + ' signal ' + Rule.Render args[0]
			f: ->
				@entity.emit.apply @entity, arguments
				
				increment: 1
	
		setName: (name) ->
			@state.name = name
			
			increment: 1
		
		setX: (x) ->
			@entity.setPosition [x, @state.position[1]]
			
			increment: 1
			
		setY: (y) ->
			@entity.setPosition [@state.position[0], y]
			
			increment: 1
			
		setPosition: (position) ->
			return if Vector.equals @state.position, position
			
			oldPosition = Vector.copy @state.position
			@state.position = position
			@entity.emit 'positionChanged', oldPosition
			
			increment: 1
		
		setWidth: (width) ->
			@entity.setSize [width, @state.size[1]]
			
			increment: 1
			
		setHeight: (height) ->
			@entity.setSize [@state.size[0], height]
			
			increment: 1
			
		setSize: (size) ->
			return if Vector.equals @state.size, size
			
			oldSize = Vector.copy @state.size
			@state.size = size
			@entity.emit 'sizeChanged', oldSize
			
			increment: 1
		
		setDirection:
			argTypes: ['Number']
			argNames: ['Direction']
			renderer: (candidate, args) ->
				"set #{candidate} direction to #{Rule.Render args[0]}"
			name: 'Set direction'
			f: (direction) ->
				oldDirection = @state.direction
				
				@state.direction = if direction < 0
					0
				else if direction > @entity.directionCount()
					@entity.directionCount() - 1
				else
					direction
				
				if @state.direction isnt oldDirection
					@entity.emit 'directionChanged', @state.direction
				
				increment: 1
				
		setDirectionCount: (directionCount) ->
			
			@state.directionCount = directionCount

	handler: ->
		
		ticker: ->
			
			@state.secondsSeen += Timing.TimingService.tickElapsed()
