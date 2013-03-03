# **DisplayCommand** is an abstract base class to implement a display
# command.

EventEmitter = require 'Utility/EventEmitter'
Mixin = require 'Utility/Mixin'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = class

	constructor: (@list_, rectangle = [0, 0, 0, 0]) ->
		
		Mixin this, EventEmitter
		
		@rectangle_ = [0, 0, 0, 0]
		@setRectangle rectangle
		@setIsRelative true
		
		@list_.addCommand this
		@markAsDirty true
	
	list: -> @list_
		
	markAsDirty: (rectangle) ->
		
	setIsRelative: (isRelative) -> @isRelative_ = isRelative
	isRelative: -> @isRelative_
	
	setRectangle: (rectangle) ->
		
		return if @rectangle_? and Rectangle.equals rectangle, @rectangle_
		
		@markAsDirty rectangle
		@rectangle_ = Rectangle.round rectangle
		
	rectangle: -> @rectangle_
	
	setPosition: (position) ->
		
		@setRectangle Rectangle.compose(
			position
			Rectangle.size @rectangle_
		)
		
	position: -> Rectangle.position @rectangle_
	
	setSize: (size) ->
		
		@setRectangle Rectangle.compose(
			Rectangle.position @rectangle_
			size
		)
		
	size: -> Rectangle.size @rectangle_
	
	calculateRelativePosition: (position, offset) ->
		
		if @isRelative()
			position
		else
			Vector.add(
				offset
				position
			)
			
	relativeRectangle: ->
		
		position = @calculateRelativePosition @position(), @list_.position()
		
		Rectangle.compose(
			position
			@size()
		)
		
	render: (position, clip, destination) ->
