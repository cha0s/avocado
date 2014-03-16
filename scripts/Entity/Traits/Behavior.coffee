
_ = require 'Utility/underscore'
EventEmitter = require 'Mixin/EventEmitter'
Method = require 'Entity/Traits/Behavior/Method'
Mixin = require 'Mixin/Mixin'
ObjectExt = require 'Extension/Object'
Promise = require 'Utility/bluebird'
Trait = require 'Entity/Traits/Trait'

class Actions

	mixins = [
		EventEmitter
	]
	
	constructor: (@actions, @entity, @variables) ->
		mixin.call @ for mixin in mixins
		
		@entityTicker = null
		@index = 0
		@locked = false
		@tickers = []
		
	Mixin.apply null, [@::].concat mixins
	
	removeEntityTicker: -> @entity.removeTicker @entityTicker
	
	removeTickers: -> @entity.removeTicker ticker for ticker in @tickers
	
	runOnEntity: ->
	
		deferred = Promise.defer()
		
		@entity.addTicker @entityTicker = noEmit: true, f: =>
			return if @locked
			@locked = true
	
			listener = (ticker) => @tickers.push ticker
			
			methodCompleted = (result) =>
				
				@removeTickers()
				
				@locked = false
				
				if (@index += result?.increment ? 1) >= @actions.length
					@setIndex 0
					
					@removeEntityTicker()
					
					deferred.resolve()
			
			# Catch any tickers added.
			@entity.on 'tickerAdded', listener
			
			promiseOrValue = Method.EvaluateManually(
				@variables
				@actions[@index].Method
			)
			
			@entity.off 'tickerAdded', listener
			
			if Promise.is promiseOrValue
				promiseOrValue.done methodCompleted
			else
				methodCompleted promiseOrValue
				
			return
		
		deferred.promise
		
	setIndex: (@index) ->
	
	stop: ->
		
		@locked = false
		@removeEntityTicker()
		@removeTickers()
	
module.exports = Behavior = class extends Trait
	
	stateDefaults: ->
		
		behaving: true
		evaluatingRules: true
		executingRoutine: true
		routineIndex: null
		routines: {}
		rules: []
	
	constructor: (entity, state) ->
		super
		
		@routines = {}
		@rules = []
		@variables =
			entity: entity
			Global: require 'Entity/Traits/Behavior/Global'
			Vector: require 'Extension/Vector'
	
	initializeTrait: ->
		
		for name, routine of @routines = ObjectExt.deepCopy @state.routines
			routine.actions = new Actions routine.actions, @entity, @variables
		
		@startExecutingRoutine()
		
		rulePromises = for ruleO in @state.rules.concat()
			rule = new Rule()
			rule.fromObject ruleO
		
		Promise.all(rulePromises).then (@rules) =>
	
	setVariables: (variables) -> _.extend @variables, variables
	
	evaluateRules: ->
		rule.evaluate @variables for rule in @rules
		return
	
	_executeRoutine: ->
		return unless (routine = @routines[@state.routineIndex])?
		
		(@entity.executeActions routine['actions']).then =>
			@_executeRoutine()
			
		return
	
	startExecutingRoutine: ->
		return unless (routine = @routines[@state.routineIndex])?
		
		routine.actions.setIndex 0
		
		@_executeRoutine()
		
	stopExecutingRoutine: ->
		return unless @routine?
		
		@routine.actions.stop()
		
	properties: ->
		
		behaving: {}
		evaluatingRules: {}
		executingRoutine: {}
		routineIndex:
			set: (routineIndex, actionIndex = 0) ->
				
				@stopExecutingRoutine()
				
				unless @routines[@state.routineIndex = routineIndex]?
					throw new Error 'No such routine'
				
				@startExecutingRoutine()
				
				# Otherwise the action index would increment in the new
				# routine.
				increment: 0 
	
	actions: ->
		
		executeActions: (actions) ->
			
			unless actions instanceof Actions
				actions = new Actions actions, @entity, @variables
			
			actions.runOnEntity()
			
		async: (actions) ->
			
			@entity.executeActions actions
			
			return
		
		parallel: (actions) ->
			
			promises = for action in actions
				
				Method.EvaluateManually(
					@variables
					action.Method
				)
			
			Promise.allAsap promises
		
	values: ->
		
		hasRoutine: (routineName) -> @routines[routineName]?
		
		routine: -> @routine
		
	handler: ->
		
		ticker: ->
			
			return unless @entity.behaving()
			
			@evaluateRules() if @entity.evaluatingRules()
			
			return
