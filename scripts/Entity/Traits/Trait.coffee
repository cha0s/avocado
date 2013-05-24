_ = require 'Utility/underscore'
upon = require 'Utility/upon'

module.exports = class

	# Currently unused: map Trait modules 
	@moduleMap = {}
	
	# Extend the state with defaults. Make sure you call from children!
	constructor: (@entity, state = {}) ->
		@state = _.defaults state, @stateDefaults()
	
	# Extend with your state defaults.
	stateDefaults: -> {}
	
	# Emit the trait as a JSON representation.
	toJSON: ->
		
		sgfy = JSON.stringify
		
		state = {}
		stateDefaults = @stateDefaults()
		
		for k, v of _.defaults @state, JSON.parse sgfy stateDefaults
			state[k] = v if sgfy(v) isnt sgfy(stateDefaults[k])
			
		O = {}
		O.type = @type
		O.state = state unless _.isEmpty state
		O
	
	hooks: -> {}
	
	signals: -> {}
	
	actions: -> {}
	
	values: -> {}
	
	initializeTrait: -> upon.resolve()
	
	resetTrait: ->
	
	removeTrait: ->
	
	transient: false
