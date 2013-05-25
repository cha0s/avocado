
Trait = require 'Entity/Traits/Trait'

module.exports = class extends Trait

	stateDefaults: ->
		
		foo: true
		bar: false
	
	resetTrait: ->
		
		@state.baz = 420
		
	setVariables: (variables) ->
		
		@state.blah = variables.blah if variables.blah?
		
	hooks: ->
		
		testHook: (thing) -> "HOOK: #{thing}"
	
	signals: ->
		
		testSignal: -> @state.foo = 69
	
	values: ->
		
		foo: -> @state.foo
		bar: -> @state.bar
		baz: -> @state.baz
		blah: -> @state.blah
		
	actions: ->
		
		setFoo: (foo) -> @state.foo = foo
		setBar: (bar) -> @state.bar = bar
		setBaz: (baz) -> @state.baz = baz
