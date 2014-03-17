# # Entity
# Specifies objects in the game engine. Entities are essentially just
# compositions of (subclassed) [`Trait`](./Traits/Trait.html) objects.

Timing = require 'Timing'

_ = require 'Utility/underscore'
CoreService = require('Core').CoreService
Debug = require 'Debug'
EventEmitter = require 'Mixin/EventEmitter'
FunctionExt = require 'Extension/Function'
Lfo = require 'Mixin/Lfo'
Mixin = require 'Mixin/Mixin'
Promise = require 'Utility/bluebird'
String = require 'Extension/String'
Ticker = require 'Timing/Ticker'
Transition = require 'Mixin/Transition'
uuid = require 'Utility/uuid'

# Entities provide an interface for registering 'tickers'. A ticker is a
# function which repeats on an interval, such as the function that updates an
# entity's current animation, as in the Visibility trait.
# 
# Tickers are pooled in frequency contexts. Frequency contexts are lists of
# tickers, keyed by the frequency of their interval. For instance, if an entity
# has 3 tickers set to run every 50 ms, and 2 tickers set to run every 30 ms,
# there will only be two frequency contexts created, keyed on 50 and 30,
# respectively. This allows us to have many tickers registered on the same
# frequency, without allocating a Timing/Ticker for each ticker.
class FrequencyContext
	
	contexts = {}
	
	constructor: (frequency) ->
		contexts[frequency] = this
		
		@_frequencySeconds = frequency / 1000
		@_list = {}
		@_ticker = new Ticker.InBand frequency
		
		@_ticker.on 'tick', @onTick, @
	
	# TODO, insert in place, don't concat and sort, that's inefficient.
	addTicker: (uuid, ticker) ->
		@_list[uuid] = (
			@_list[uuid] ?= []
		).concat([
			ticker
		]).sort (l, r) -> l.weight - r.weight
		
	onTick: ->
	
		# Remember and hack the tick elapsed time so that the ticker can trust
		# it.
		tickElapsed = Timing.TimingService.tickElapsed()
		Timing.TimingService.setTickElapsed @_frequencySeconds
		
		# For each entity (uuid):
		for _uuid, tickers of @_list
			continue unless tickers?
			
			# Run all the tickers. The when condition is weird, but it will
			# prevent race conditions from tickers being removed within their
			# own tick.
			ticker.f() for ticker, i in tickers when i < tickers.length
		
		# Reset the tick elapsed time to the real value.
		Timing.TimingService.setTickElapsed tickElapsed
		
	removeEntity: (uuid) -> @_list[uuid] = null
	
	removeTicker: (uuid, ticker) ->
		return unless @_list[uuid]?
		return if -1 is index = @_list[uuid].indexOf ticker
		return @removeEntity uuid if @_list[uuid].length is 1
		
		@_list[uuid].splice index, 1
	
	tick: -> @_ticker.tick()

	@findOrCreate: (frequency) ->
		if contexts[frequency]?
			contexts[frequency]
		else
			new FrequencyContext frequency
	
	@removeEntity: (uuid) ->
		context.removeEntity uuid for frequency, context of contexts
	
	@removeTicker: (uuid, ticker) ->
		context.removeTicker uuid, ticker for frequency, context of contexts
	
	@tick: -> context.tick() for frequency, context of contexts
	
module.exports = Entity = class Entity
	
	# #### Mixins
	# 
	# * [`EventEmitter`](../Mixin/EventEmitter.html) for trait signals.
	# * [`Transition`](../Mixin/Transition.html) for transitioning any
	#    property.
	mixins = [
		EventEmitter
		Lfo.InBand
		Transition.InBand
	]
	
	constructor: ->
		mixin.call @ for mixin in mixins
		
		@_originalTraits = {}
		@_renderers = {}
		@_traits = {}
		@_uri = null
		@_uuid = uuid.v4()
		
		@on 'isDestroyedChanged', (wasDestroyed = true) ->
			FrequencyContext.removeEntity @_uuid unless wasDestroyed
	
		# All entities require an Existence trait. The assumption here is that
		# Existence::initializeTrait() returns an immediate value (not a
		# promise).
		@extendTraits [type: 'Existence']
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	# Add a ticker to this entity.
	addTicker: (ticker) ->
		
		ticker = normalizeTickerSpec ticker
		
		context = FrequencyContext.findOrCreate ticker.frequency
		context.addTicker @_uuid, ticker
		
		ticker
		
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
				Debug.errorMessage error
			}"
		
		trait.type = type
		@_traits[trait.type] = trait
		
		# Bind properties
		for key, meta of trait['properties']()
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
			for index, meta of trait[type]()
				
				if @[index]?
					throw new Error "Duplicate #{type} registered against #{trait.type}: #{index} (originally from #{@[index].type})"
				
				@[index] = _.bind meta.f ? meta, trait
				@[index].type = trait.type
		
		# Refresh the signals associated with this trait.
		@off ".#{trait.type}Trait"
		for index, signal of trait['signals']()
			@on "#{index}.#{trait.type}Trait", signal, trait
		
		# Add the handlers associated with this trait.
		if handler = trait['handler']?()
			
			if (ticker = handler['ticker'])?
				
				ticker = normalizeTickerSpec ticker
				ticker.f = _.bind ticker.f, trait
				
				@addTicker ticker
			
			if handler['renderer']?
				
				renderers = if _.isFunction handler['renderer']
					inline: handler['renderer']
				else
					handler['renderer']
				
				for key, spec of renderers
					renderer = normalizeRendererSpec spec
					renderer.trait = trait
					renderer.f = _.bind renderer.f, trait
					
					(@_renderers[key] ?= []).push renderer
					
		# Cache hooks to make lookups more efficient.
		trait['hookCache'] = trait['hooks']()
		
		@_renderers[key] = @_renderers[key].sort(
			(l, r) -> l.weight - r.weight
		) for key, list of @_renderers
		
		trait
		
	_coalesceTraits: (allTraits) ->
		traitMap = {}
		@_traitDependencies traitMap, trait for trait in allTraits
		trait for type, trait of traitMap
	
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
			continue if not trait['hookCache'][hook]?
			continue unless results = FunctionExt.fastApply(
				trait['hookCache'][hook], args, trait
			)
			results
		
	lfo: ->
		
		lfo = FunctionExt.fastApply Lfo.InBand::lfo, arguments, this
		
		return lfo unless lfo.promise?
		
		ticker =
			f: -> lfo.tick()
			frequency: 33
		
		ticker = @addTicker ticker
		
		removeTicker = => @removeTicker ticker
		
		lfo.promise.then(
			removeTicker
		).catch Promise.CancellationError, (error) ->
			removeTicker()

			canceled: true
			
		lfo
		
	removeTicker: (ticker) -> FrequencyContext.removeTicker @_uuid, ticker
	
	# Remove a Trait from this Entity.
	removeTrait: (type) ->
		
		trait = @_traits[type]
		
		# Fire Trait::removeTrait().
		trait.removeTrait()
		
		# Remove the actions and values.
		delete @[index] for index of trait['actions']()
		delete @[index] for index of trait['values']()
	
		# Remove the handlers.
		# TODO this is broken since the ticker change
#		@_tickers = _.filter @_tickers, (e) -> e.trait.type isnt type
#
#		@_renderers[key] = _.filter(
#			@_renderers[key]
#			(e) -> e.trait.type isnt type
#		) for key, list of @_renderers
		
		# Remove the trait object.
		delete @_traits[type]
	
	# Called every engine render cycle.
	render: (destination, camera = [0, 0], type = 'inline') ->
		
		renderer.f destination, camera for renderer in @_renderers[type] ? []
		return

	_requireTrait: (type) -> require "Entity/Traits/#{Entity.traitModule type}"
	
	# Reset traits.			
	reset: ->
		trait.resetTrait() for type, trait of @_traits
		return
	
	# Set trait variables.
	setTraitVariables: (variables) ->
		trait.setVariables variables for type, trait of @_traits
		return
		
	# Initialize an Entity from a POD object.
	# Emit a JSON representation of the entity.
	toJSON: ->
		
		traits = for type, trait of @_traits
			continue if trait['transient']
			trait.toJSON()
		
		traits: traits
	
	# Get a trait by name.
	trait: (traitName) -> @_traits[traitName]
	
	_traitDependencies: (traitMap, trait) ->
		
		try
			
			Trait = @_requireTrait trait.type
			traitMap[trait.type] = trait
			
		catch error
			
			console.warn Debug.errorMessage error
			console.warn "Ignoring entity trait: #{trait.type}"
			
			return
			
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
		
	transition: ->
		
		transition = FunctionExt.fastApply(
			Transition.InBand::transition, arguments, this
		)
		
		ticker =
			f: -> transition.tick()
			frequency: 33
		
		ticker = @addTicker ticker
		
		removeTicker = => @removeTicker ticker
		
		transition.promise.then(
			removeTicker
		).catch Promise.CancellationError, (error) ->
			removeTicker()

			canceled: true
			
		transition
	
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
	
			CoreService.readJsonResource(uri).then (O) ->
				
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
		
		Trait = require 'Entity/Traits/Trait'
		
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
