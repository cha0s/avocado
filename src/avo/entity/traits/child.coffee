
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
	
	actions: ->
		
		setParent: (@_parent) ->
			
			if @state.isAttachedToParent
				
				@_parent.on 'positionChanged', =>
					
					position = Vector.copy @_parent.position()
					
					for attachedOffset in @entity.invoke 'attachedOffset'
						position = Vector.add(
							position
							attachedOffset
						)
					
					@entity.setPosition position
		
	hooks: ->
		
		zIndex: ->
			
			if @state.isAbove
				@entity.parent().y() + .0001
			else
				@entity.parent().y() - .0001
		
	values: ->
		
		parent: -> @_parent
		
