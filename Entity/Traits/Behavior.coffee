_ = require 'Utility/underscore'
Method = require 'Entity/Traits/Behavior/Method'
Trait = require 'Entity/Traits/Trait'
upon = require 'Utility/upon'

module.exports = Behavior = class extends Trait
	
	@variables = {}
	@setVariables: (variables) ->
		for key, value of variables
			@variables[key] = value
	
	defaults: ->
		
		rules: []
		routines: []
		behaving: true
		evaluatingRules: true
		executingRoutine: true
	
	constructor: (entity, state) ->
	
		super entity, state
		
		@routines = []
		@rules = []
		@variables =
			entity: entity
			trait: this
		
	setVariables: (@variables) ->
		
		rule.setVariables @variables for rule in @rules
		
		undefined
	
	randomRange: (min, max = min) ->
			
		min + Math.floor Math.random() * (1 + max - min)
	
	evaluateRules: -> rule.evaluate() for rule in @rules
	
	executeRoutine: ->
		
		allVariables = {}
		for source in [Behavior.variables, @variables]
			allVariables[k] = v for k, v of source
		
		result = Method.Evaluate.apply(
			Method.Evaluate
			[allVariables].concat @routine['actions'][@actionIndex].Method
		)
		
		@actionIndex += result?.increment ? 1
		if @actionIndex >= @routine['actions'].length
			@actionIndex = 0
	
	initializeTrait: ->
		
		@routines = @state.routines.concat()
		@routine = @routines[@actionIndex = 0]
		
		@rules = for ruleO in @state.rules.concat()
			rule = new Rule()
			rule.fromObject ruleO
			rule
		
		upon.all([
		])
			
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
