# # Entity
# Specifies objects in the game engine. Entities are essentially just
# compositions of (subclassed) [`Trait`](./Traits/Trait.html) objects.

_ = require 'Utility/underscore'
CoreService = require('Core').CoreService
Debug = require 'Debug'
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'
PrivateScope = require 'Utility/PrivateScope'
Q = require 'Utility/Q'
String = require 'Extension/String'
Transition = require 'Mixin/Transition'

module.exports = Entity = class
	
	# #### Mixins
	# 
	# * [`EventEmitter`](../Mixin/EventEmitter.html) for trait signals.
	# * [`Transition`](../Mixin/Transition.html) for transitioning any
	#    property.
	mixins = [
		EventEmitter
		Transition.InBand
	]
	
	# Instantiation
	constructor: ->
		
		mixin.call this for mixin in mixins
		PrivateScope.call @, Private, 'entityScope'
			
		# All entities require an Existence trait. The assumption here is that
		# Existence::initializeTrait() returns an immediate value (not a
		# promise).
		@extendTraits([type: 'Existence']).done()
		
	Mixin.apply null, [@::].concat mixins
	
	forwardCallToPrivate = (call) => PrivateScope.forwardCall(
		@::, call, (-> Private), 'entityScope'
	)
	
	forwardCallToPrivate 'extendTraits'
	
	forwardCallToPrivate 'fromObject'
	
	forwardCallToPrivate 'hasTrait'
	
	forwardCallToPrivate 'invoke'
	
	forwardCallToPrivate 'removeTrait'
	
	forwardCallToPrivate 'render'
	
	forwardCallToPrivate 'reset'
	
	forwardCallToPrivate 'setTraitVariables'
	
	forwardCallToPrivate 'tick'
	
	forwardCallToPrivate 'toJSON'
	
	forwardCallToPrivate 'trait'
	
	forwardCallToPrivate 'traitExtensions'
	
	uri: ->
		
		_private = @entityScope Private
		_private.uri
	
	traitArrayToObject = (traits) ->
		object = {}
		object[trait.type] = trait.state ? {} for trait in traits
		object
	
	# Load an entity by URI.
	@load: (uri, traitExtensions = []) ->
	
		loadObject = (uri) ->
	
			CoreService.readJsonResource(uri).then (O) ->
				
				{parent, traits} = O
				
				if parent?
					
					loadObject(parent).then (O) ->
						
						childTraits = traitArrayToObject traits
						parentTraits = traitArrayToObject O.traits
						
						traitTypes = _.uniq _.flatten [
							_.keys childTraits
							_.keys parentTraits
						]
						
						O.traits = for traitType in traitTypes
							
							state = _.extend(
								parentTraits[traitType] ? {}
								childTraits[traitType] ? {}
							)
							
							type: traitType
							state: state unless _.isEmpty state
							
						O
				else
					
					O
		
		loadObject(uri).then (O) ->
			O.uri = uri
			
			entity = new Entity()
			objectPromise = entity.fromObject O
			
			if traitExtensions.length
				objectPromise.then (entity) ->
					entity.extendTraits traitExtensions
					entity
			else
				objectPromise
		
	@traitModule: (traitName) ->
		
		Trait = require 'Entity/Traits/Trait'
		
		if Trait.moduleMap[traitName]
			Trait.moduleMap[traitName]
		else
			traitName
	
	Private = class
		
		requireTrait: (type) -> require "Entity/Traits/#{Entity.traitModule type}"
		
		constructor: ->

			@originalTraits = {}
			@renderers = {}
			@tickers = []
			@traits = {}
			@uri = null

		addTrait: (traitInfo) ->
			
			_public = @public()
			
			# Instantiate and insert the Trait.
			type = traitInfo.type
			Trait = @requireTrait type
				
			try
				trait = new Trait _public, traitInfo.state
			catch error
				throw new Error "Can't instantiate #{
					type
				} trait: #{
					Debug.errorMessage error
				}"
			
			trait.type = type
			@traits[trait.type] = trait
			
			# Bind properties
			for key, meta of trait['properties']()
				do (key, meta) =>
					
					# Getter.
					_public[key] = _.bind (meta.get ? -> @state[key]), trait
					
					# Setter and comparison.
					eq = meta.eq ? (l, r) -> l is r
					setter = meta.set ? (value) -> @state[key] = value
					_public[String.setterName key] = (value) =>
						oldValue = _public[key]()
						setter.apply trait, arguments
						_public.emit "#{key}Changed" unless eq oldValue, trait.state[key]
						
			# Bind the actions and values associated with this trait.
			for type in ['actions', 'values']
				for index, meta of trait[type]()
					_public[index] = _.bind meta.f ? meta, trait
			
			# Refresh the signals associated with this trait.
			_public.off ".#{trait.type}Trait"
			for index, signal of trait['signals']()
				_public.on "#{index}.#{trait.type}Trait", signal, trait
			
			addHandlerToList = (handler, list) =>
			
				# Normalize the handler object.
				unless handler.f
					f = handler
					handler = f: f
				
				handler.f = _.bind handler.f, trait
				handler.trait = trait
				handler.weight ?= 0
			
				# Add the handler.
				list.push handler
					
			# Add the handlers associated with this trait.
			if handler = trait['handler']?()
				
				if handler['ticker']?
					addHandlerToList handler['ticker'], @tickers
				
				if handler['renderer']?
					
					if _.isFunction handler['renderer']
						
						addHandlerToList(
							handler['renderer'], @renderers['inline'] ?= []
						)
						
					else
						
						addHandlerToList(
							spec, @renderers[key] ?= []
						) for key, spec of handler['renderer']
							
			# Cache hooks to make lookups more efficient.
			trait['hookCache'] = trait['hooks']()
			
			# Sort all the tickers and renderers by weight.
			@tickers = @tickers.sort (l, r) -> l.weight - r.weight
			
			@renderers[key] = @renderers[key].sort(
				(l, r) -> l.weight - r.weight
			) for key, list of @renderers
			
			trait
			
		coalesceTraits: (allTraits) ->
			traitMap = {}
			@traitDependencies traitMap, trait for trait in allTraits
			trait for type, trait of traitMap
		
		# Extend this Entity's traits.
		extendTraits: (traits) ->
			
			_public = @public()
			
			# Wrap all the trait promises in a promise and return it.	
			traits = for trait in @coalesceTraits traits
				
				{type, state} = trait
				
				# If the trait already exists,
				if @traits[type]?
					
					# extend the state,
					_.extend @traits[type].state, state
					
					# and fire Trait::initializeTrait().
					@traits[type]
				
				# Otherwise, add the trait.
				else
					
					@addTrait trait
				
			Q.allAsap(
				_.map traits, (trait) -> trait.initializeTrait()
				=>
					trait.resetTrait() for type, trait of @traits
					_public
			)
				
		fromObject: (O) ->
			
			_public = @public()
			
			{traits} = O
			
			@uri = O.uri
			
			# Add traits asynchronously.
			_public.extendTraits(traits).then =>
				
				@originalTraits = JSON.parse JSON.stringify @traits
				_public
	
		# Check whether this Entity has a trait.
		hasTrait: (traitName) -> @traits[traitName]?
		
		# Invoke a hook with the specified arguments. Returns an array of responses
		# from hook implementations.
		invoke: (hook, args...) ->
			for type, trait of @traits
				continue if not trait['hookCache'][hook]?
				trait['hookCache'][hook].apply trait, args
	
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
	
			@renderers[key] = _.filter(
				@renderers[key]
				(e) -> e.trait.type isnt type
			) for key, list of @renderers
			
			# Remove the trait object.
			delete @traits[type]
		
		# Called every engine render cycle.
		render: (destination, camera = [0, 0], type = 'inline') ->
			
			_public = @public()
			
			renderer.f destination, camera for renderer in @renderers[type] ? []
			_public.emit 'render', type
			return
	
		# Reset traits.			
		reset: ->
			trait.resetTrait() for type, trait of @traits
			return
		
		# Set trait variables.
		setTraitVariables: (variables) ->
			trait.setVariables variables for type, trait of @traits
			return
			
		# Called every engine tick.
		tick: ->
			
			_public = @public()
			
			ticker.f() for ticker in @tickers
			_public.emit 'tick'
			return
			
		# Initialize an Entity from a POD object.
		# Emit a JSON representation of the entity.
		toJSON: ->
			
			traits = for type, trait of @traits
				continue if trait['transient']
				trait.toJSON()
			
			traits: traits
		
		# Get a trait by name.
		trait: (traitName) -> @traits[traitName]
		
		traitDependencies: (traitMap, trait) ->
			
			try
				
				Trait = @requireTrait trait.type
				traitMap[trait.type] = trait
				
			catch error
				
				console.log Debug.errorMessage error
				console.log "Ignoring entity trait: #{trait.type}"
				
				return
				
			for dependency in Trait.dependencies ? []
				continue if traitMap[dependency]?
				
				@traitDependencies traitMap, type: dependency
		
		traitExtensions: ->
			
			_public = @public()
			
			O = _public.toJSON()
			
			originalTraits = {}
			for k, v of @originalTraits
				originalTraits[k] = v.state ? {}
			
			currentTraits = traitArrayToObject O.traits
			
			O.traits = []
			
			sgfy = JSON.stringify.bind JSON
			
			for type, currentState of currentTraits
			
				unless originalTraits[type]?
					O.traits.push
						type: type
						state: currentState unless _.isEmpty currentState
					
					continue
					
				state = {}
				stateDefaults = originalTraits[type]
				
				for k, v of _.defaults currentState, JSON.parse sgfy stateDefaults
					state[k] = v if sgfy(v) isnt sgfy(stateDefaults[k])
					
				traitO = type: type
				
				if _.isEmpty state
					continue if originalTraits[type]?
				else
					traitO.state = state
				
				O.traits.push traitO
			
			delete O.traits unless O.traits.length > 0
			
			O
			