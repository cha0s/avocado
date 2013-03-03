
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	defaults: ->
		x: -10000
		y: -10000
	
		width:  0
		height: 0
		
		directionCount: 1
		direction: 0
		
		name: 'Abstract'
	
	resetTrait: ->
		
		# Set direction and force emit the event.
		@entity.setDirection @state.direction
		@entity.emit 'directionChanged', @state.direction
		
	values: ->
			
		x: -> @state.x
		
		y: -> @state.y
		
		position:
			result: 'Position'
			f: -> [@state.x, @state.y]
		
		width: -> @state.width
		
		height: -> @state.height
		
		size: -> [@state.width, @state.height]
		
		rectangle:
			result: 'Rectangle'
			name: 'Rectangle'
			renderer: (candidate, args) -> candidate + ' rectangle'
			f: ->
				
				Array.composeRect(
					Vector.scale(
						Vector.sub @entity.position(), @size()
						.5
					)
					@size()
				)
		
		direction:
			
			result: 'Number'
			f: -> @state.direction
		
		directionCount: -> @state.directionCount
			
		name: -> @state.name
		
	actions: ->
		
		nop:
			name: 'Do nothing'
			renderer: -> 'do nothing'
			f: ->
		
		removeTraitType:
			f: (type) -> @entity.removeTrait type
		
		signal:
			name: 'Emit signal'
			argTypes: ['String']
			argNames: ['Signal']
			renderer: (candidate, args) ->
				'emit ' + candidate + ' signal ' + Rule.Render args[0]
			f: ->
				
				@entity.emit.apply this, arguments
				
				increment: 1
	
		setName: (name) -> @state.name = name
		
		setX: (x) -> @setPosition x, @y()

		setY: (y) -> @setPosition @x(), y
		
		setPosition: (position) ->
			
			[@state.x, @state.y] = position
			
			@entity.emit 'positionChanged'
		
		setWidth: (width) -> @state.width = width
		
		setHeight: (height) -> @state.height = height
		
		setSize: (size) -> [@state.width, @state.height] = size
		
		setDirection:
			argTypes: ['Number']
			argNames: ['Direction']
			renderer: (candidate, args) ->
				'set ' + candidate + ' direction to ' + Rule.Render args[0]
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
