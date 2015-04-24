
FunctionExt = require 'avo/extension/function'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

Transition = require 'avo/mixin/transition'

timing = require 'avo/timing'

Trait = require './trait'

module.exports = Corporeal = class extends Trait

  stateDefaults: ->

  	direction: 0
  	directionCount: 1
  	immovable: false
  	offset: [0, 0]
  	position: [-10000, -10000]
  	rotation: 0

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

  values: ->

  	hypotenuseToEntity: (entity) ->

  		Vector.hypotenuse entity.position(), @state.position

  	offsetX: -> @state.offset[0]

  	offsetY: -> @state.offset[1]

  	x: -> @state.position[0]

  	y: -> @state.position[1]

  	zIndex: -> @_zIndex

  actions: ->

  	applyImpulse: (vector, force) ->
  		return if @entity.immovable()

  		if @entity.physicsApplyImpulse?

  			@entity.physicsApplyImpulse vector, force

  		# Naive movement.
  		else

  			@entity.setPosition Vector.add(
  				@entity.position()
  				Vector.scale vector, timing.tickElapsed() * force
  			)

  	quickElastic: (properties, duration, state) ->

  		elapsedSoFar = 0

  		transitionResult = FunctionExt.fastApply(
  			Transition.InBand::transition
  			[properties, duration * 3, 'easeOutElastic']
  			@entity
  		)

  		state.setTicker ->

  			if duration <= elapsedSoFar += timing.tickElapsed() * 1000
  				transitionResult.skipTransition()

  			transitionResult.tick()

  		state.setPromise transitionResult.promise

  	setOffsetX: (x) -> @entity.setOffset [x, @entity.offsetY()]

  	setOffsetY: (y) -> @entity.setOffset [@entity.offsetX(), y]

  	setX: (x) -> @entity.setPosition [x, @state.position[1]]

  	setY: (y) -> @entity.setPosition [@state.position[0], y]

  signals: ->

  	positionChanged: -> @entity.emit 'updateZIndex'

  	traitsChanged: -> @entity.emit 'updateZIndex'

  	updateZIndex: ->

  		@_zIndex = if @entity.customZIndex?

  			@entity.customZIndex()

  		# If no one cared about movement, we'll just use y.
  		else

  			@state.position[1]
