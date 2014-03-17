
Timing = require 'Timing'

_ = require 'Utility/underscore'
FunctionExt = require 'Extension/Function'
Mixin = require 'Mixin/Mixin'
Promise = require 'Utility/bluebird'
Rectangle = require 'Extension/Rectangle'
Ticker = require 'Timing/Ticker'
Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = Existence = class extends Trait

	stateDefaults: ->
		
		isDestroyed: false
		direction: 0
		directionCount: 1
		immovable: false
		name: 'Abstract'
		offset: [0, 0]
		position: [-10000, -10000]
		secondsSeen: 0
		size: [0, 0]
		
	constructor: ->
		super
		
		@parent = null
		
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
		isDestroyed: {}
		name: {}
		offset: 
			set: (offset) -> @state.offset = Vector.copy offset
			eq: (l, r) -> Vector.equals l, r
		position:
			set: (position) -> @state.position = Vector.copy position
			eq: (l, r) -> Vector.equals l, r
		size:
			set: (size) -> @state.size = Vector.copy size
			eq: (l, r) -> Vector.equals l, r
	
	values: ->
		
		height: -> @state.size[1]
		
		offsetX: -> @state.offset[0]
		
		offsetY: -> @state.offset[1]
		
		parent: -> @parent
	
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
		
		secondsSeen: -> @state.secondsSeen

	actions: ->
		
		forceMove: (vector, force) ->
			return if @entity.immovable()
			
			moveInvocations = @entity.invoke(
				'moveRequest'
				vector, force
			)
			
			# If no one cared about movement, we'll just do naive movement.
			if moveInvocations.length is 0
				
				@entity.setPosition Vector.add(
					[@entity.x(), @entity.y()]
					Vector.scale(
						vector
						Timing.TimingService.tickElapsed() * force
					)
				)
				
		setHeight: (height) -> @entity.setSize [@state.size[0], height]
			
		setOffsetX: (x) -> @entity.setOffset [x, @entity.offsetY()]
		
		setOffsetY: (y) -> @entity.setOffset [@entity.offsetX(), y]
		
		setParent: (parent) -> @parent = parent
		
		setWidth: (width) -> @entity.setSize [width, @state.size[1]]
			
		setX: (x) -> @entity.setPosition [x, @state.position[1]]
			
		setY: (y) -> @entity.setPosition [@state.position[0], y]
			
		signal: -> FunctionExt.fastApply @entity.emit, arguments, @entity
	
		waitMs:
			
			f: (ms) ->
				
				deferred = Promise.defer()
				
				ticker = new Ticker.InBand()
				ticker.setFrequency ms
				@entity.addTicker waitTicker = f: -> ticker.tick()
				
				removeTicker = => @entity.removeTicker waitTicker
				
				ticker.on 'tick', => deferred.resolve()
				
				deferred.promise.cancellable().then(->
					removeTicker()
				).catch Promise.CancellationError, (error) ->
					removeTicker()
					
					canceled: true

	handler: ->
		
		ticker: ->
			
			@state.secondsSeen += Timing.TimingService.tickElapsed()
