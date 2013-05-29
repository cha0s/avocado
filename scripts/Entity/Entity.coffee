# The **Entity** class specifies objects in the game engine. Entities are
# merely compositions of (subclassed) [Trait](Traits/Trait.html) objects.

_ = require 'Utility/underscore'
CoreService = require('Core').CoreService
Debug = require 'Debug'
EventEmitter = require 'Utility/EventEmitter'
Mixin = require 'Utility/Mixin'
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Transition = require 'Utility/Transition'
Vector = require 'Extension/Vector'

module.exports = Entity = class
	
	# Load an entity by URI.
	@load: (uri) ->
		CoreService.readJsonResource(uri).then (O) ->
			O.uri = uri
			entity = new Entity()
			entity.fromObject O
		
	@traitModule: (traitName) ->
		
		Trait = require 'Entity/Traits/Trait'
		
		if Trait.moduleMap[traitName]
			Trait.moduleMap[traitName]
		else
			traitName
	
	requireTrait = (type) ->
		require "Entity/Traits/#{Entity.traitModule type}"
	
	# ***Internal:*** Add an array of [Trait](Traits/Trait.html) PODs to this
	# entity.
	addTrait = (traitInfo) ->
		
		# Instantiate and insert the Trait.
		type = Entity.traitModule traitInfo.type
		Trait = require "Entity/Traits/#{type}"
		
		try
			trait = new Trait this, traitInfo.state
		catch error
			throw new Error "Can't instantiate #{
				type
			} trait: #{
				Debug.errorMessage error
			}"
		
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
		
		# Sort all the tickers and renderers by weight.
		@tickers = @tickers.sort (l, r) -> l.weight - r.weight
		@renderers = @renderers.sort (l, r) -> l.weight - r.weight
		
		trait.initializeTrait()
		
	# Instantiation
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
		
		# All entities require an Existence trait. It is hacky, but we have
		# to work around that trait initialization is asynchronous (for now).
		addTrait.call(this, type: 'Existence').done()
		@traits['Existence'].resetTrait()
		
	# Initialize an Entity from a POD object.
	fromObject: (O) ->
		
		{@uri, traits} = O
		
		@originalTraits = JSON.parse JSON.stringify traits

		# Add traits asynchronously.
		@extendTraits traits
			
	# Deep copy.
	copy: ->
		entity = new Entity()
		entity.fromObject @toJSON()
		entity
	
	# Extend this Entity's traits.
	extendTraits: (traits) ->
		
		traits = _.filter traits, (trait) ->
			
			try
				
				require "Entity/Traits/#{Entity.traitModule trait.type}"
				true
				
			catch error
				
				console.log Debug.errorMessage error
				console.log "Ignoring entity trait: #{trait.type}"
				false
			
		# Wrap all the trait promises in a promise and return it.	
		traitsPromises = for trait in traits
			
			{type, state} = trait
			
			# If the trait already exists,
			promise = if @traits[type]?
				
				# extend the state,
				_.extend @traits[type].state, state
				
				# and fire Trait::initializeTrait().
				@traits[type].initializeTrait()
			
			# Otherwise, add the trait.
			else
				
				addTrait.call this, trait
			
			((trait) -> promise.then -> trait.resetTrait()) @traits[type]
			
		Q.all(traitsPromises).then => this
			
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

	# Called every engine tick.
	tick: (commandList) -> ticker.f() for ticker in @tickers
	
	# Called every engine render cycle.
	render: (camera, destination) ->
		for renderer in @renderers
			renderer.f.call this, destination, camera
		return

	# Reset traits.			
	reset: ->
		trait.resetTrait() for type, trait of @traits
		return
	
	# Set trait variables.
	setTraitVariables: (variables) ->
		trait.setVariables variables for type, trait of @traits
		return
		
	# Emit a JSON representation of the entity.
	toJSON: ->
		
		traits = for type, trait of @traits
			continue if trait['transient']
			trait.toJSON()
		
		uri: @uri
		traits: traits
