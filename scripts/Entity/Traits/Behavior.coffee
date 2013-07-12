
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
		routines: [
			name: 'Default'
			actions: [
				Method: [
					'Global:nop'
					[
						[]
					]
				]
			]
		]
		rules: []
	
	constructor: (entity, state) ->
	
		super entity, state
		
		@routines = []
		@routineNames = []
		@routinePromiseLock = false
		@rules = []
		@tickers = []
		@variables =
			entity: entity
			Global: require 'Entity/Traits/Behavior/Global'
			Vector: require 'Extension/Vector'
		
	initializeTrait: ->
		
		@routines = @state.routines.concat()
		@routineNames = _.pluck @routines, 'name'
		
		for routine in _.flatten(
			@entity.invoke 'routines'
			true
		)
			unless _.contains @routines, routine.name
				@routines.push routine
				@routineNames.push routine.name
		
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
		
		@entity.on 'tickerAdded.BehaviorTrait', (ticker) =>
			@tickers.push ticker
		
		promiseOrValue = Method.EvaluateManually(
			@variables
			@routine['actions'][actionIndex].Method
		)
		
		fulfill = (result) =>
			
			@releaseAsync()
			
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
				
				@releaseAsync()
				
				@routine = @routines[@state.routineIndex = routineIndex]
				@entity.setActionIndex actionIndex
				unless @routine['actions'][actionIndex]?
					throw new Error 'No such command index'
					
				# Return a promise that never resolves, because otherwise the
				# action index would increment in the new routine.
				Q.defer().promise
	
	releaseAsync: ->
	
		@routinePromiseLock = false
		
		@entity.removeTicker ticker for ticker in @tickers
		@tickers = []
		@entity.off 'tickerAdded.BehaviorTrait'
		
	actions: ->
		
		parallel: (actions) ->
			
			deferred = Q.defer()
			
			ticker = f: (skipFirstCheck = false) =>
				
				for action in actions
					unless skipFirstCheck
						continue if Q.isPromise action.result
						continue if action.result?.increment ? 1
					
					action.result = Method.EvaluateManually(
						@variables
						action.Method
					)
					
					continue if Q.isPending action.result
					continue if action.result?.increment is 0

				for action in actions
					return if Q.isPending action.result
					return if action.result?.increment is 0
					
				deferred.resolve()
			
			ticker.f true
			
			@entity.addTicker ticker
			
			deferred.promise
		
		setRoutineIndexByName: (routineName, actionIndex = 0) ->
			return if @routine?['name'] is routineName
			
			if -1 is routineIndex = @routineNames.indexOf routineName
				throw new Error 'routine[' + routineName + '] does not exist!'
			
			@entity.setRoutineIndex routineIndex, actionIndex
	
	values: ->
		
		hasRoutine: (routineName) -> _.contains @routineNames, routineName
		
		routine: -> @routine
		
	handler: ->
		
		ticker: ->
			
			return unless @entity.behaving()
			
			@evaluateRules() if @entity.evaluatingRules()
			
			@executeRoutine() if @entity.executingRoutine()
