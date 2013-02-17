# The **Entity** class specifies objects in the game engine. Entities are
# merely compositions of (subclassed) [Trait](Traits/Trait.html) objects.

_ = require 'Utility/underscore'
CoreService = require('Core').CoreService
DisplayCommand = require 'Graphics/DisplayCommand'
EventEmitter = require 'Utility/EventEmitter'
Logger = require 'Utility/Logger'
Mixin = require 'Utility/Mixin'
Rectangle = require 'Extension/Rectangle'
Transition = require 'Utility/Transition'
upon = require 'Utility/upon'
Vector = require 'Extension/Vector'

module.exports = Entity = class
	
	#### Instantiation
	constructor: ->
		
		# Mixins
		# 
		# * **[EventEmitter](../Utility/EventEmitter.html)** for Existence::emit()
		# * **[Transition](../Utility/Transition.html)** for transitioning any property.
		Mixin this, EventEmitter, Transition
		
		# Initialize members.
		@traits = {}

		@tickers = []
		@renderers = []
		
		# Children entities.
		@children = []
		
		# All entities require an Existence trait. Calling extendTraits() here 
		# seems risky, but Existence::initializeTrait will always be synchronous
		# (to keep entity instantiation sane).
		@extendTraits [
			type: 'Existence'
		]
		
	# Initialize an Entity from a POD object.
	fromObject: (O, variables) ->
		
		defer = upon.defer()
		
		{@uri, traits} = O

		# Add traits asynchronously.
		@extendTraits(traits, variables).then ->
			
			defer.resolve()
			
		defer.promise
			
	# Load an entity by URI.
	@load: (uri, variables = {}) ->
		
		defer = upon.defer()
		
		CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			
			entity = new Entity()
			entity.fromObject(O, variables).then ->
				
				defer.resolve entity
		
		defer.promise
	
	@traitModule: (traitName) ->
		
		Trait = require 'Entity/Traits/Trait'
		
		if Trait.moduleMap[traitName]
			Trait.moduleMap[traitName]
		else
			traitName
	
	# Deep copy.
	copy: (variables = {}) ->
		
		entity = new Entity()
		entity.fromObject @toJSON(), variables
		
		entity
	
	# ***Internal:*** Add an array of [Trait](Traits/Trait.html) PODs to this entity.
	addTraits = (traits, variables) ->
		
		# nop.
		if not traits?
			defer = upon.defer()
			defer.resolve()
			return defer.promise
		
		# Sort all the tickers and renderers by weight.
		@tickers = @tickers.sort (l, r) -> l.weight - r.weight
		@renderers = @renderers.sort (l, r) -> l.weight - r.weight
		
		# Promise the traits:
		for traitInfo in traits
			
			# Instantiate and insert the Trait.
			type = Entity.traitModule traitInfo.type
			Trait = require "Entity/Traits/#{type}"
			trait = new Trait this, traitInfo.state
			trait.type = type
			@traits[trait.type] = trait
			
			# Bind the actions and values associated with this trait.
			for type in ['actions', 'values']
				for index, meta of trait[type]()
					@[index] = _.bind meta.f ? meta, trait
			
			# Refresh the signals associated with this trait.
			for index, signal of trait['signals']()
				name = "#{index}.#{trait.type}Trait"
				@off name 
				@on name, signal, trait
			
			# Refresh the handlers associated with this trait.
			if handler = trait['handler']?()
				
				for handlerType in ['ticker', 'renderer']
					continue unless handler[handlerType]?
					
					# Remove any existing handler.
					@["#{handlerType}s"] = _.filter @["#{handlerType}s"], (e) ->
						e.trait isnt trait.type
				
					# Normalize the handler object.
					unless handler[handlerType].f
						f = handler[handlerType]
						handler[handlerType] = {}
						handler[handlerType].f = f
					
					handler[handlerType].f = _.bind(
						handler[handlerType].f
						trait
					)
					handler[handlerType].weight ?= 0
					handler[handlerType].trait = trait
				
					# Add the handler.
					@["#{handlerType}s"].push handler[handlerType]
			
			trait.initializeTrait variables
		
	# Extend this Entity's traits.
	extendTraits: (traits, variables = {}) ->
		
		traits = _.filter traits, (trait) ->
			
			try
				
				require "Entity/Traits/#{Entity.traitModule trait.type}"
				true
				
			catch e
				
				console.log e.stack
				Logger.warn "Ignoring unknown entity trait: #{trait.type}"
				false
			
		# Wrap all the trait promises in a promise and return it.	
		traitsPromise = for trait in traits
			
			# If the trait already exists,
			if @traits[trait.type]?
				
				{type, state} = trait
				
				# extend the state,
				_.extend @traits[type].state, state
				
				# and fire Trait::initializeTrait().
				@traits[type].initializeTrait variables
			
			# Otherwise, add the traits as new.
			# TODO aggregate for efficiency.	
			else
				
				addTraits.call this, [trait], variables
				
		upon.all _.flatten traitsPromise, true
			
	# Remove a Trait from this Entity.
	removeTrait: (type) ->
		
		trait = @traits[type]
		
		# Fire Trait::removeTrait().
		trait.removeTrait()
		
		# Remove the actions and values.
		delete @[index] for index of trait['actions']()
		delete @[index] for index of trait['values']()
	
		# Remove the handlers.
		@tickers = _.filter @tickers, (e) -> e.trait.type isnt type
		@renderers = _.filter @renderers, (e) -> e.trait.type isnt type
		
		# Remove the trait object.
		delete @traits[type]
	
	# Check whether this Entity has a trait.
	hasTrait: (trait) -> @traits[Entity.traitModule trait]?
	
	# Get a trait by name.
	trait: (traitName) -> @traits[Entity.traitModule traitName]
	
	# Invoke a hook with the specified arguments. Returns an array of responses
	# from hook implementations.
	invoke: (hook, args...) ->
		
		for type, trait of @traits
			continue if not trait['hooks']()[hook]?
			
			trait['hooks']()[hook].apply trait, args

	tick: (commandList) ->
		
		ticker.f() for ticker in @tickers
		
		child.tick() for child in @children
		
	render: (camera, destination) ->
		
		rect = Rectangle.translated(
			@visibleRect()
			Vector.sub @position(), camera
		)
	
		for renderer in @renderers
			
			renderer.f.call(
				this
				destination
				Rectangle.position rect
			)
			
		child.render position, destination for child in @children
		
	reset: -> 
		
		trait.resetTrait() for type, trait of @traits
		
		child.reset() for child in @children
		
	toJSON: ->
		
		uri: @uri
		traits: for type, trait of @traits
			continue if trait.transient
			trait.toJSON()

module.exports.DisplayCommandList = class extends DisplayCommand
	
	constructor: (
		list
		rectangle = [0, 0, 0, 0]
	) ->
		
		@entities = []
		
		super list, rectangle
		
	rectangleFromEntity: (entity) ->
		
		Rectangle.translated(
			entity.visibleRect()
			entity.position()
		)
		
	rectangleFromEntities: ->
		
		rectangle = [0, 0, 0, 0]
		
		for entity in @entities
			
			continue unless entity.hasTrait 'Visibility'
			
			rectangle = Rectangle.united(
				rectangle
				@rectangleFromEntity entity
			)
		
		rectangle
		
	addEntity: (entity) ->
		
		return if _.contains @entities, entity
		
		entity.on 'positionChanged.EntityDisplayCommand', =>
			
			@setRectangle @rectangleFromEntities()
			
		entity.on 'renderUpdate.EntityDisplayCommand', =>
			
			@markAsDirty()
			
		@entities.push entity
		
		@setRectangle @rectangleFromEntities()
		
		@addEntity child for child in entity.children
		
	removeEntity: (entity) ->
		
		entity.off '.EntityDisplayCommand'
		
		index = @entities.indexOf entity
		
		return if index is -1
		
		@entities.splice index, 1
		
		@setRectangle @rectangleFromEntities()
		
		@removeEntity child for child in entity.children
		
	render: (position, clip, destination) ->
		
		for entity in (
			
			(_.filter @entities, (entity) ->
				entity.hasTrait 'Visibility'
			).sort (l, r) =>
				
				l.y() - r.y()
		)
			
			rectangle = @rectangleFromEntity entity
			
			entityClip = Rectangle.intersection(
				rectangle
				Rectangle.translated clip, @position()
			)
			
			continue if Rectangle.isNull entityClip
			
			entityPosition = Vector.round Vector.sub(
				Rectangle.position entityClip
				@list_.position()
			)
			
			entityClipPosition = Vector.sub(
				Rectangle.position entityClip
				Rectangle.position rectangle
			)
			
			entityClip = Rectangle.round Rectangle.compose(
				entityClipPosition
				Vector.sub(
					Rectangle.size rectangle
					entityClipPosition
				)
			) 
			
			for renderer in entity.renderers
				
				renderer.f.call entity, destination, entityPosition, entityClip
				
			# TODO: debugging
			
			destination.drawCircle(
				Vector.round Vector.sub(
					entity.position()
					@list_.position()
				)
				4
				255, 255, 255, 180
			)
			
			
		undefined
