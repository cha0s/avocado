
_ = require 'Utility/underscore'
EventEmitter = require 'Mixin/EventEmitter'
FunctionExt = require 'Extension/Function'
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
		@pendingAction = null
		@tickers = []
		
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	removeEntityTicker: -> @entity.removeTicker @entityTicker
	
	runOnEntity: ->
	
		deferred = Promise.defer()
		
		@entityTicker = @entity.addTicker f: =>
			return if @pendingAction?
	
			methodCompleted = (result) =>
				return if result?.canceled
				
				@pendingAction = null
				
				if (@index += result?.increment ? 1) >= @actions.length
					@setIndex 0
					
					@removeEntityTicker()
					
					deferred.resolve()
					
			@pendingAction = Method.EvaluateManually(
				@variables
				@actions[@index].Method
			)
			
			if Promise.is @pendingAction
				@pendingAction.done methodCompleted
			else
				methodCompleted @pendingAction
				
			return
		
		deferred.promise
		
	setIndex: (@index) ->
	
	stop: ->
		
		@removeEntityTicker()
		
		@pendingAction?.cancel()
		@pendingAction = null
	
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
		
		@routine = null
		@routines = {}
		@rules = []
		@variables =
			entity: entity
			Global: require 'Entity/Traits/Behavior/Global'
			Vector: require 'Extension/Vector'
	
	initializeTrait: ->
		
		for name, routine of @routines = ObjectExt.deepCopy @state.routines
			routine.actions = new Actions routine.actions, @entity, @variables
		
		
		for routines in @entity.invoke 'routines'
			for index, routine of routines
				continue if @routines[index]?
				
				routine.actions = new Actions routine.actions, @entity, @variables
				@routines[index] = routine
			
		@routine = @routines[@state.routineIndex]
		@entity.startExecutingRoutine() if @state.behaving
		
		rulePromises = for ruleO in @state.rules.concat()
			rule = new Rule()
			rule.fromObject ruleO
		
		Promise.all(rulePromises).then (@rules) =>
	
	setVariables: (variables) -> _.extend @variables, variables
	
	evaluateRules: ->
		rule.evaluate @variables for rule in @rules
		return
	
	_executeRoutine: ->
		
		(@entity.executeActions @routine['actions']).then =>
			
			@_executeRoutine()
			
			return
			
		return
	
	properties: ->
		
		behaving: {}
		evaluatingRules: {}
		executingRoutine: {}
		routineIndex:
			set: (routineIndex, actionIndex = 0) ->
				
				@routine = @routines[@state.routineIndex = routineIndex]
				
	actions: ->
		
		executeRoutine: -> @entity.executeActions @routine['actions']
		
		startExecutingRoutine: ->
			return unless @routine?
			
			@routine.actions.setIndex 0
			
			@_executeRoutine()
			
			return
			
		stopExecutingRoutine: ->
			return unless @routine?
			
			@routine.actions.stop()
			
		executeActions: (actions) ->
			
			unless actions instanceof Actions
				actions = new Actions actions, @entity, @variables
			
			actions.runOnEntity()
			
		async: (actions, count = 1) ->
			
			@entity.executeActions actions
			
			return
		
		parallel: (actions) ->
			
			promises = for action in actions
				
				Method.EvaluateManually(
					@variables
					action.Method
				)
				
			Promise.all(promises).cancellable().catch(
				Promise.CancellationError, (error) ->
					for promise, i in promises
						promise.cancel()

					canceled: true
			)
			
	values: ->
		
		hasRoutine: (routineName) -> @routines[routineName]?
		
		routine: -> @routine
		
	handler: ->
		
		ticker: ->
			
			return unless @entity.behaving()
			
			@evaluateRules() if @entity.evaluatingRules()
			
			return
