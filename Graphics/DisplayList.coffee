# **DisplayList** is a
# [display list](http://en.wikipedia.org/wiki/Display_list). It is used for
# rendering graphics scene in an optimized way.
#
# The display list manages which parts of the scene have actually changed, and
# only renders the changes.

_ = require 'Utility/underscore'
QuadTree = require 'Utility/QuadTree'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = class
	
	constructor: (rectangle, worldRectangle) ->
		
		args = Rectangle.toObject worldRectangle, true
		args.maxChildren = 2
		args.maxDepth = 4
		
		@quadTree = new QuadTree args
		
		@lastDirtyRectangle_ = [0, 0, 0, 0]
		@dirtyCommands_ = {}
		
		@clear()
		@setRectangle rectangle
		
	setRectangle: (rectangle) ->
		return if @rectangle_? and Rectangle.equals @rectangle_, rectangle
		
		@rectangle_ = rectangle
		@lastDirtyRectangle_ = [0, 0, 0, 0]
		@markAllCommandsAsDirty()
		
	rectangle: -> @rectangle_
	
	setSize: (size) -> @setRectangle Rectangle.compose(
		Rectangle.position @rectangle_
		size
	)
	
	size: -> Rectangle.size @rectangle_
	
	setPosition: (position) -> @setRectangle Rectangle.compose(
		position
		Rectangle.size @rectangle_
	)
	
	position: -> Rectangle.position @rectangle_
	
	addCommandToQuadTree: (command) ->
	
		O = Rectangle.toObject(
			command.relativeRectangle()
			true
		)
		O.command = command
		command.O = O
		O.toJSON = ->
			x: @x
			y: @y
			w: @w
			h: @h
		
		@quadTree.insert O
		
	addCommand: (command) ->
		
		command.commandId_ = @commandId_++
		@commands_.push command
		
		# Add it to the QuadTree.
		@addCommandToQuadTree command
		
		command.markAsDirty = (
			rectangle = command.relativeRectangle()
		) =>
			
			@dirtyCommands_[command.commandId_] = command
			
			@lastDirtyRectangle_ = Rectangle.united(
				@lastDirtyRectangle_
				Rectangle.intersection(
					rectangle
					@rectangle_
				)
			)
			
		command.markAsDirty()
	
	clear: ->
		
		@commandId_ = 0
		@commands_ = []
		@dirtyCommands_ = {}
		@quadTree.clear()
	
	markRectangleAsDirty: (rectangle) ->
		
		affectedCommands = @quadTree.retrieve(
			Rectangle.toObject(
				rectangle
				true
			)
		)
		affectedCommands = _.map affectedCommands, (O) -> O.command
		
		command.markAsDirty rectangle for command in affectedCommands
		
	markAllCommandsAsDirty: ->
	
		@markRectangleAsDirty @rectangle_
	
	render: (destination) ->
		renderRectangles = []
		
		return renderRectangles if _.isEmpty @dirtyCommands_
		
		sortCommands = (commands) ->
			
			_.sortBy commands, 'commandId_'
		
		renderCommand = (command, intersection) =>
			
			# The actual position where rendering occurs.
			position = Rectangle.position intersection
			position = Vector.sub(
				position
				Rectangle.position @rectangle_
			)
			
			# The clipping rectangle for rendering this command.
			clip = Rectangle.compose(
				Vector.sub(
					position
					Vector.sub(
						Rectangle.position command.relativeRectangle()
						Rectangle.position @rectangle_
					)
				)
				Rectangle.size intersection
			)
			
			# Render this command.
			command.render position, clip, destination
			
		# Keep track of the display offset so we can translate the resulting
		# dirty rectangle back later.
		offset = Vector.scale(
			Rectangle.position @rectangle_
			-1
		)
		
		dirtyRectangle = [0, 0, 0, 0]
		dirtyCommands = []
		
		@dirtyCommands_ = (v for k, v of @dirtyCommands_) 
		for dirtyCommand in sortCommands @dirtyCommands_
			
			intersection = Rectangle.intersection(
				dirtyCommand.relativeRectangle()
				@rectangle_
			)
			continue if Rectangle.isNull intersection
			
			dirtyCommands.push dirtyCommand
			
			dirtyRectangle = Rectangle.united dirtyRectangle, intersection
			
		totalDirtyRectangle = Rectangle.intersection(
			Rectangle.united @lastDirtyRectangle_, dirtyRectangle
			@rectangle_
		)
		
		@quadTree.clear()
		for command in @commands_
			@addCommandToQuadTree command
		
		affectedCommands = @quadTree.retrieve(
			Rectangle.toObject(
				totalDirtyRectangle
				true
			)
		)
		affectedCommands = _.map affectedCommands, (O) -> O.command
		affectedCommands = sortCommands affectedCommands
		
		cleanCommands = _.difference affectedCommands, @dirtyCommands_
		if cleanCommands.length > 0
			for command in cleanCommands
				
				intersection = Rectangle.intersection(
					command.relativeRectangle()
					@lastDirtyRectangle_
				)
				continue if Rectangle.isNull intersection
				
				renderCommand command, intersection
				
			dirtyCommands = sortCommands dirtyCommands.concat cleanCommands
			
		for command in dirtyCommands

			intersection = Rectangle.intersection(
				command.relativeRectangle()
				dirtyRectangle
			)
			continue if Rectangle.isNull intersection
			
			renderCommand command, intersection
			
		@lastDirtyRectangle_ = [0, 0, 0, 0]
		@dirtyCommands_ = {}
		
		renderRectangles.push(
			totalDirtyRectangle
		)
		
		# Let caller know which areas are actually dirty.
		_.map renderRectangles, (renderRectangle) ->
			Rectangle.translated renderRectangle, offset
