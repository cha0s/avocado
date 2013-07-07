
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
		
		Q.asap(
			Method.EvaluateManually(
				@variables
				@routine['actions'][actionIndex].Method
			)
			(result) =>
				@routinePromiseLock = false	
				
				actionIndex += result?.increment ? 1
				if actionIndex >= @routine['actions'].length
					actionIndex = 0
					
					@entity.emit 'finishedRoutine', @routine
					
				@entity.setActionIndex actionIndex
		)
		
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
			
	actions: ->
		
		parallel: (actions) ->
			
			promisesOrResults = for action in actions
				
				Method.EvaluateManually(
					@variables
					action.Method
				)
			
			Q.all promisesOrResults
			
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
			@executeRoutine() if @entity.executingRoutine()
