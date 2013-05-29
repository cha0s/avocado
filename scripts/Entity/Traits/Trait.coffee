_ = require 'Utility/underscore'
Q = require 'Utility/Q'

module.exports = class

	# Currently unused: map Trait modules 
	@moduleMap = {}
	
	# Extend the state with defaults. Make sure you call from children!
	constructor: (@entity, state = {}) ->
		unless _.isObject defaults = @stateDefaults()
			throw new Error "State defaults must be an object."
		@state = _.defaults state, defaults
	
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
	
	initializeTrait: -> Q.resolve()
	
	resetTrait: ->
	
	removeTrait: ->
	
	setVariables: (variables) ->
	
	transient: false
