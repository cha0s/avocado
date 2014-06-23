# # Entity
# Specifies objects in the game engine. Entities are essentially just
# compositions of (subclassed) [`Trait`](./Traits/Trait.html) objects.

_ = require 'avo/vendor/underscore'
EventEmitter = require 'avo/mixin/eventEmitter'
fs = require 'avo/fs'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Promise = require 'avo/vendor/bluebird'
String = require 'avo/extension/string'
uuid = require 'avo/vendor/uuid'

module.exports = Entity = class Entity
	
	# #### Mixins
	# 
	# * [`EventEmitter`](../Mixin/EventEmitter.html) for trait signals.
	mixins = [
		EventEmitter
	]
	
	constructor: ->
		mixin.call @ for mixin in mixins
		
		@_context = {}
		@_originalTraits = {}
		@_renderers = {}
		@_tickers = []
		@_traits = {}
		@_uri = null
		@_uuid = uuid.v4()
		
		# All entities require an Existence trait. The assumption here is that
		# Existence::initializeTrait() returns an immediate value (not a
		# promise).
		@extendTraits [type: 'existent']
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	_addTrait: (traitInfo) ->
		
		# Instantiate and insert the Trait.
		type = traitInfo.type
		Trait = @_requireTrait type
			
		try
			trait = new Trait @, traitInfo.state
		catch error
			throw new Error "Can't instantiate #{
				type
			} trait: #{
				error
			}"
		
		trait.type = type
		@_traits[trait.type] = trait
		
		# Bind properties
		for key, meta of trait._properties
			do (key, meta) =>
				
				# Getter.
				@[key] = _.bind (meta.get ? -> @state[key]), trait
				
				# Setter and comparison.
				eq = meta.eq ? (l, r) -> l is r
				setter = meta.set ? (value) -> @state[key] = value
				@[String.setterName key] = (value) =>
					oldValue = trait.state[key]
					FunctionExt.fastApply setter, arguments, trait
					@emit "#{key}Changed", oldValue unless eq oldValue, trait.state[key]
		
		# Bind the actions and values associated with this trait.
		for type in ['actions', 'values']
			for index, meta of trait["_#{type}"]
				
				throw new Error "Duplicate #{
					type
				} registered against #{
					trait.type
				}: #{
					index
				} (originally from #{
					@[index].type
				})" if @[index]?
				
				@[index] = _.bind meta.f ? meta, trait
				@[index].type = trait.type
		
		# Refresh the signals associated with this trait.
		@off ".#{trait.type}Trait"
		for index, signal of trait._signals
			@on "#{index}.#{trait.type}Trait", signal, trait
		
		# Add the handlers associated with this trait.
		if handler = trait._handler
			
			if (ticker = handler['ticker'])?
				
				ticker = normalizeTickerSpec ticker
				ticker.f = _.bind ticker.f, trait
				ticker.type = trait.type
				
				@_tickers.push ticker
				
				@_tickers = @_tickers.sort(
					(l, r) -> l.weight - r.weight
				) for ticker in @_tickers
			
			if handler['renderer']?
				
				renderers = if _.isFunction handler['renderer']
					inline: handler['renderer']
				else
					handler['renderer']
				
				for key, spec of renderers
					renderer = normalizeRendererSpec spec
					renderer.type = trait.type
					renderer.f = _.bind renderer.f, trait
					
					(@_renderers[key] ?= []).push renderer
					
				@_renderers[key] = @_renderers[key].sort(
					(l, r) -> l.weight - r.weight
				) for key, list of @_renderers
		
		trait

	_coalesceTraits: (allTraits) ->
		traitMap = {}
		@_traitDependencies traitMap, trait for trait in allTraits
		trait for type, trait of traitMap
	
	context: -> @_context
	
	# Extend this Entity's traits.
	extendTraits: (traits) ->
		
		# Wrap all the trait promises in a promise and return it.	
		traits = for trait in @_coalesceTraits traits
			
			{type, state} = trait
			
			# If the trait already exists,
			if @_traits[type]?
				
				# extend the state,
				_.extend @_traits[type].state, state
				
				# and fire Trait::initializeTrait().
				@_traits[type]
			
			# Otherwise, add the trait.
			else
				
				@_addTrait trait
			
		Promise.allAsap(
			_.map traits, (trait) -> trait.initializeTrait()
			=>
				trait.resetTrait() for type, trait of @_traits
				@
		)
			
	# Initialize an Entity from a POD object.
	fromObject: (O) ->
		
		{traits} = O
		
		@_uri = O.uri
		
		# Add traits asynchronously.
		Promise.asap(
			@extendTraits traits
			=>
				@_originalTraits = JSON.parse JSON.stringify @_traits
				@
		)

	# Check whether this Entity has a trait.
	hasTrait: (traitName) -> @_traits[traitName]?
	
	# Invoke a hook with the specified arguments. Returns an array of responses
	# from hook implementations.
	invoke: (hook) ->
	
		args = if arguments.length > 1
			arg for arg, i in arguments when i > 0
		else
			[]
	
		for type, trait of @_traits
			continue if not trait._hooks[hook]?
			continue unless results = FunctionExt.fastApply(
				trait._hooks[hook], args, trait
			)
			results
		
	# Remove a Trait from this Entity.
	removeTrait: (type) ->
		
		trait = @_traits[type]
		
		# Fire Trait::removeTrait().
		trait.removeTrait()
		
		# Remove the actions and values.
		delete @[index] for index of trait['actions']()
		delete @[index] for index of trait['values']()
	
		# Remove the handlers.
		@_tickers = _.filter @_tickers, (e) -> e.type isnt type

		@_renderers[key] = _.filter(
			@_renderers[key]
			(e) -> e.type isnt type
		) for key, list of @_renderers

		# Remove the trait object.
		delete @_traits[type]
	
	# Called every engine render cycle.
	render: (destination, camera = [0, 0], type = 'inline') ->
		
		renderer.f destination, camera for renderer in @_renderers[type] ? []
		return

	_requireTrait: (type) -> require "avo/entity/traits/#{type}"
	
	# Reset traits.			
	reset: ->
		
		trait.resetTrait() for type, trait of @_traits
		return
	
	tick: ->
		
		for ticker in @_tickers
			
			ticker.f()
	
	# Emit a JSON representation of the entity.
	toJSON: ->
		
		traits = for type, trait of @_traits
			continue if trait.ephemeral
			trait.toJSON()
		
		traits: traits
	
	# Get a trait by name.
	trait: (traitName) -> @_traits[traitName]
	
	_traitDependencies: (traitMap, trait) ->
		
		Trait = @_requireTrait trait.type
		traitMap[trait.type] = trait
			
		for dependency in Trait.dependencies ? []
			continue if traitMap[dependency]?
			
			@_traitDependencies traitMap, type: dependency
	
	traitArrayToObject = (traits) ->
		object = {}
		object[trait.type] = trait.state ? {} for trait in traits
		object
	
	traitExtensions: ->
		
		O = @toJSON()
		
		originalTraits = {}
		for k, v of @_originalTraits
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
	
	uri: -> @_uri
	
	# Load an entity by URI.
	@load: (uri, traitExtensions = []) ->
		
		extendTraits = (current, extended) ->
		
			currentTraits = traitArrayToObject(
				JSON.parse JSON.stringify current
			)
			extendedTraits = traitArrayToObject(
				JSON.parse JSON.stringify extended
			)
			
			traitTypes = _.uniq _.flatten [
				_.keys currentTraits
				_.keys extendedTraits
			]
			
			for traitType in traitTypes
				
				state = _.extend(
					extendedTraits[traitType] ? {}
					currentTraits[traitType] ? {}
				)
				
				type: traitType
				state: state unless _.isEmpty state

		loadObject = (uri) ->
	
			fs.readJsonResource(uri).then (O) ->
				
				{parent, traits} = O
				
				if parent?
					
					loadObject(parent).then (O) ->
						O.traits = extendTraits traits, O.traits
						O
				else
					
					O
		
		loadObject(uri).then (O) ->
			O.uri = uri
			O.traits = extendTraits O.traits, traitExtensions
			
			(new Entity()).fromObject O
		
	@tick: -> FrequencyContext.tick()
		
	@traitModule: (traitName) ->
		
		Trait = require 'avo/entity/traits/trait'
		
		if Trait.moduleMap[traitName]
			Trait.moduleMap[traitName]
		else
			traitName
	
	# A handler (a renderer or a ticker) has two forms of specification. The
	# more advanced form of this specification allows setting the function and
	# the handler in a specification object. The simpler case is simply a
	# function, in which case, the object specification is created around the
	# function, with sane defaults.
	normalizeHandlerSpec = (handler) ->
		
		unless handler.f?
			f = handler
			handler = f: f
	
		handler.weight ?= 0
		
		handler
	
	# A ticker specification implements a frequency default over the base
	# handler.
	normalizeTickerSpec = (ticker) ->
		
		ticker = normalizeHandlerSpec ticker
		
		ticker.frequency ?= 1000 / 60
		
		ticker
			
	# A renderer specification implements no extension over the base handler.
	normalizeRendererSpec = normalizeHandlerSpec
