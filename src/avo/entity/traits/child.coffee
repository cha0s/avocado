
Vector = require 'avo/extension/vector'

Trait = require './trait'

module.exports = class Child extends Trait

  stateDefaults: ->

  	isAbove: true
  	isAttachedToParent: true

  constructor: ->
  	super

  	@_parent = null

  properties: ->

  	isAbove: {}
  	isAttachedToParent: {}

  _setPositionFromParent: ->

  	position = Vector.copy @_parent.position()


  	position = Vector.add(
  		position
  		attachedOffset
  	) for attachedOffset in @entity.invoke 'attachedOffset'

  	@entity.setPosition position

  	@entity.emit 'updateZIndex'

  actions: ->

  	setParent: (@_parent) ->

  		if @state.isAttachedToParent
  			@_setPositionFromParent()
  			@_parent.on 'positionChanged', => @_setPositionFromParent()

  values: ->

  	customZIndex: ->
  		return @entity.y() unless (parent = @entity.parent())?

  		if @state.isAbove
  			parent.y() + .0001
  		else
  			parent.y() - .0001

  	parent: -> @_parent

