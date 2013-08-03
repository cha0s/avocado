# # Entity
# Specifies objects in the game engine. Entities are essentially just
# compositions of (subclassed) [`Trait`](./Traits/Trait.html) objects.

Timing = require 'Timing'

_ = require 'Utility/underscore'
CoreService = require('Core').CoreService
Debug = require 'Debug'
EventEmitter = require 'Mixin/EventEmitter'
Lfo = require 'Mixin/Lfo'
Mixin = require 'Mixin/Mixin'
Q = require 'Utility/Q'
String = require 'Extension/String'
Ticker = require 'Timing/Ticker'
Transition = require 'Mixin/Transition'
uuid = require 'Utility/uuid'

tickers = {}

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
		@_tickers = {}
		@_traits = {}
		@_uri = null
		@_uuid = uuid.v4()
		
		@on 'isDestroyedChanged', (wasDestroyed = true) ->
			unless wasDestroyed
				delete list[@_uuid] for frequency, {list} of tickers
	
		# All entities require an Existence trait. The assumption here is that
		# Existence::initializeTrait() returns an immediate value (not a
		# promise).
		@extendTraits [type: 'Existence']
		
	Mixin.apply null, [@::].concat mixins
	
	addTicker: (ticker) ->
		
		ticker = @_normalizeHandler ticker
		
		frequency = ticker.frequency ?= 16.6
		
		unless tickers[frequency]?
			tickers[frequency] =
				list: {}
				ticker: new Ticker.InBand()
		
			tickers[frequency].ticker.setFrequency frequency
			frequencySeconds = frequency / 1000
			
			tickers[frequency].ticker.on 'tick', ->
				
				tickElapsed = Timing.TimingService.tickElapsed()
				Timing.TimingService.setTickElapsed frequencySeconds
				
				for _uuid in Object.keys tickers[frequency].list
					_tickers = tickers[frequency].list[_uuid]
					
					continue unless _tickers?
					
					for _ticker, i in _tickers when i < _tickers.length
						_ticker.f()
				
				Timing.TimingService.setTickElapsed tickElapsed
		
		list = (tickers[frequency].list[@_uuid] ?= []).concat [ticker]
		tickers[frequency].list[@_uuid] = list.sort (l, r) ->
			l.weight - r.weight
		
		@emit 'tickerAdded', ticker
		
		ticker
		
	_normalizeHandler: (handler) ->
		
		unless handler.f?
			f = handler
			handler = f: f

		handler.weight ?= 0
		
		handler
	
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
					setter.apply trait, arguments
					@emit "#{key}Changed", oldValue unless eq oldValue, trait.state[key]
					
		# Bind the actions and values associated with this trait.
		for type in ['actions', 'values']
			for index, meta of trait[type]()
				@[index] = _.bind meta.f ? meta, trait
		
		# Refresh the signals associated with this trait.
		@off ".#{trait.type}Trait"
		for index, signal of trait['signals']()
			@on "#{index}.#{trait.type}Trait", signal, trait
		
		# Add the handlers associated with this trait.
		if handler = trait['handler']?()
			
			if (ticker = handler['ticker'])?
				
				ticker = @_normalizeHandler ticker
				ticker.f = _.bind ticker.f, trait
				
				@addTicker ticker
			
			if handler['renderer']?
				
				renderers = if _.isFunction handler['renderer']
					inline: handler['renderer']
				else
					handler['renderer']
				
				for key, spec of renderers
					renderer = @_normalizeHandler spec
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
			
		Q.allAsap(
			_.map traits, (trait) -> trait.initializeTrait()
			=>
				trait.resetTrait() for type, trait of @_traits
				@
		)
			
	fromObject: (O) ->
		
		{traits} = O
		
		@_uri = O.uri
		
		# Add traits asynchronously.
		Q.asap(
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
			continue unless results = trait['hookCache'][hook].apply(
				trait, args
			)
			results
		
	lfo: ->
		
		lfo = Lfo.InBand::lfo.apply(
			@, arguments
		)
		
		return lfo unless lfo.promise?
		
		ticker =
			f: -> lfo.tick()
			frequency: 33
		
		ticker = @addTicker ticker
		
		lfo.promise.then => @removeTicker ticker
			
		lfo
		
	removeTicker: (ticker) ->
		
		for frequency, {list} of tickers
			list = list[@_uuid]
			continue unless list?
			continue if -1 is index = list.indexOf ticker
			list.splice index, 1
	
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
		
		transition = Transition.InBand::transition.apply(
			@, arguments
		)
		
		ticker =
			f: -> transition.tick()
			frequency: 33
		
		ticker = @addTicker ticker
		
		transition.promise.then => @removeTicker ticker
			
		transition
	
	uri: -> @_uri
	
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
			
			Q.asap(
				entity.fromObject O
				(entity) ->
				
					if traitExtensions.length
						Q.asap(
							entity.extendTraits traitExtensions
							(entity) -> entity
						)
					else
						entity
			)
		
	@tick: ->
	
		ticker.tick() for frequency, {ticker} of tickers
		
	@traitModule: (traitName) ->
		
		Trait = require 'Entity/Traits/Trait'
		
		if Trait.moduleMap[traitName]
			Trait.moduleMap[traitName]
		else
			traitName
