_ = require 'Utility/underscore'
Method = require 'Entity/Traits/Behavior/Method'
Q = require 'Utility/Q'
Trait = require 'Entity/Traits/Trait'

module.exports = Behavior = class extends Trait
	
	stateDefaults: ->
		
		rules: []
		routines: []
		behaving: true
		evaluatingRules: true
		executingRoutine: true
	
	constructor: (entity, state) ->
	
		super entity, state
		
		@actionIndex = 0
		@routines = []
		@routinePromiseLock = false
		@rules = []
		@variables =
			entity: entity
			Global: require 'Entity/Traits/Behavior/Global'
			Vector: require 'Extension/Vector'
		
	setVariables: (variables) -> _.extend @variables, variables
	
	evaluateRules: ->
		rule.evaluate @variables for rule in @rules
		return
	
	executeRoutine: ->
		return if @routinePromiseLock
		@routinePromiseLock = true
		
		fulfill = (result) =>
			@routinePromiseLock = false	
			
			@actionIndex += result?.increment ? 1
			if @actionIndex >= @routine['actions'].length
				@actionIndex = 0
				
				@entity.emit 'finishedRoutine', @routine
		
		promiseOrResult = Method.Evaluate.apply(
			Method.Evaluate
			[@variables].concat @routine['actions'][@actionIndex].Method
		)
		
		# Promises will always wait a tick, so if it isn't a promise, fulfill
		# immediately.
		if Q.isPromise promiseOrResult
			promiseOrResult.then(fulfill).done()
		else
			fulfill promiseOrResult
		
	initializeTrait: ->
		
		@routines = @state.routines.concat()
		@routine = @routines[@actionIndex]
		
		rulePromises = for ruleO in @state.rules.concat()
			rule = new Rule()
			rule.fromObject ruleO
		
		Q.all(rulePromises).then (@rules) =>
			
	values: ->
		
		currentRoutineName: -> @routine['name']
		
		currentActionIndex: -> @actionIndex
		
	actions: ->
		
		setRoutine:
			
			name: "Set routine"
			argTypes: ['String', 'Number']
			argNames: ['Routine name', 'Action index']
			f: (routineName, actionIndex = 0) ->
				return if @routine['name'] is routineName
				
				routineNames = _.map @routines, (routine) -> routine.name
				if -1 is routineIndex = routineNames.indexOf routineName
					throw new Error 'routine[' + routineName + '] does not exist!'
				
				@routine = @routines[routineIndex]
				unless @routine['actions'][@actionIndex = actionIndex]?
					throw new Error 'No such command index'
				
				# Don't increment since the routine changed.
				increment: 0
		
		setBehaving:
			
			name: "Set behaving"
			argTypes: ['Boolean']
			argNames: ['Behaving']
			f: (behaving) -> @state.behaving = behaving
			
		setEvaluatingRules:
			
			name: "Set rules are evaluating"
			argTypes: ['Boolean']
			argNames: ['Rules are evaluating']
			f: (evaluatingRules) -> @state.evaluatingRules = evaluatingRules
			
		setExecutingRoutine:
			
			name: "Set routines are evaluating"
			argTypes: ['Boolean']
			argNames: ['Routines are evaluating']
			f: (executingRoutine) -> @state.executingRoutine = executingRoutine
			
	handler: ->
		
		ticker: ->
			
			return unless @state.behaving
			
			@evaluateRules() if @state.evaluatingRules
			@executeRoutine() if @state.executingRoutine
