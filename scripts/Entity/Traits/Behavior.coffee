
_ = require 'Utility/underscore'
Method = require 'Entity/Traits/Behavior/Method'
Q = require 'Utility/Q'
Trait = require 'Entity/Traits/Trait'

module.exports = Behavior = class extends Trait
	
	stateDefaults: ->
		
		actionIndex: 0
		behaving: true
		evaluatingRules: true
		executingRoutine: true
		routineIndex: 0
		routines: []
		rules: []
	
	constructor: (entity, state) ->
	
		super entity, state
		
		@routines = []
		@routinePromiseLock = false
		@rules = []
		@variables =
			entity: entity
			Global: require 'Entity/Traits/Behavior/Global'
			Vector: require 'Extension/Vector'
		
	initializeTrait: ->
		
		@routines = @state.routines.concat()
		@routine = @routines[@entity.routineIndex()]
		
		rulePromises = for ruleO in @state.rules.concat()
			rule = new Rule()
			rule.fromObject ruleO
		
		Q.all(rulePromises).then (@rules) =>
	
	setVariables: (variables) -> _.extend @variables, variables
	
	evaluateRules: ->
		rule.evaluate @variables for rule in @rules
		return
	
	executeRoutine: ->
		return unless @routine?
		
		return if @routinePromiseLock
		@routinePromiseLock = true
		
		actionIndex = @entity.actionIndex()
		
		promiseOrValue = Method.EvaluateManually(
			@variables
			@routine['actions'][actionIndex].Method
		)
		
		fulfill = (result) =>
			@routinePromiseLock = false	
			
			actionIndex += result?.increment ? 1
			if actionIndex >= @routine['actions'].length
				actionIndex = 0
				
				@entity.emit 'finishedRoutine', @routine
				
			@entity.setActionIndex actionIndex

		if Q.isPromise promiseOrValue
			promiseOrValue.then(fulfill).done()
		else
			fulfill promiseOrValue
		
	properties: ->
		
		actionIndex: {}
		behaving: {}
		evaluatingRules: {}
		executingRoutine: {}
		routineIndex:
			set: (routineIndex, actionIndex = 0) ->
				
				@routine = @routines[@state.routineIndex = routineIndex]
				@entity.setActionIndex actionIndex
				unless @routine['actions'][actionIndex]?
					throw new Error 'No such command index'
					
				# Don't increment; the routine changed.
				increment: 0
	
	tickParallel: (skipFirstCheck = false) ->
		return unless @parallel?
		
		for action in @parallel.actions
			unless skipFirstCheck
				continue if Q.isPromise action.result
				continue if action.result?.increment ? 1
			
			action.result = Method.EvaluateManually(
				@variables
				action.method
			)
			
		for action in @parallel.actions
			return if Q.isPending action.result
			return if action.result?.increment is 0
			
		@parallel.deferred.resolve()
		@parallel = null
			
	actions: ->
		
		parallel: (actions) ->
			
			deferred = Q.defer()
			
			@parallel =
				deferred: deferred
				actions: []
			
			promisesOrResults = for action in actions
				@parallel.actions.push
					method: action.Method
				
			@tickParallel true
			
			deferred.promise
		
		setRoutineIndexByName: (routineName, actionIndex = 0) ->
			return if @routine?['name'] is routineName
			
			routineNames = _.map @routines, (routine) -> routine.name
			if -1 is routineIndex = routineNames.indexOf routineName
				throw new Error 'routine[' + routineName + '] does not exist!'
			
			@entity.setRoutineIndex routineIndex, actionIndex
	
	values: ->
		
		routine: -> @routine
		
	handler: ->
		
		ticker: ->
			
			return unless @entity.behaving()
			
			@evaluateRules() if @entity.evaluatingRules()
			
			if @entity.executingRoutine()
				@tickParallel()
				@executeRoutine()
