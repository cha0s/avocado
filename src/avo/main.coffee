
# # Main
# 
# Execution context. The "main loop" of the Avocado engine.
# 

config = require 'avo/config'

if 'node-webkit' is config.get 'platform'
	
	util = require 'util'
	
	# I am the opposite of a fan of how node-webkit hands all logging to
	# webkit. 
	console.error = console.info = console.log = ->
		
		for arg, i in arguments
			
			process.stderr.write ' ' if i > 0
			
			if 'string' is typeof arg
				process.stderr.write arg
			else
				process.stderr.write util.inspect arg
				
		process.stderr.write '\n'
	
	# Fix PIXI and we can remove these.
	global.document = window.document
	global.navigator = window.navigator
	global.Image = window.Image
	global.HTMLImageElement = window.HTMLImageElement
	global.Float32Array = window.Float32Array
	global.Uint16Array = window.Uint16Array
	
	# Hot reload the engine when source files change.
	{Gaze} = require 'gaze'
	gaze = new Gaze [
		'avocado/src/**/*.js'
		'avocado/src/**/*.coffee'
		'src/**/*.js'
		'src/**/*.coffee'
	]
	
	gaze.watched (err, files) ->
		
		keys = Object.keys files
		
		if 0 is keys.length
			
			console.info "*** NOTE *** Hot code reloading isn't working
			correctly. In order to use this feature, you must follow the
			instructions at
			https://github.com/rogerwang/node-webkit/wiki/Using-Node-modules#3rd-party-modules-with-cc-addons
			to rebuild gaze for your version of node-webkit."
	
	gaze.on 'all', (event, filepath) ->
		gaze.close()

	gaze.on 'end', ->
		{Window} = global.window.nwDispatcher.requireNwGui()
		window_ = Window.get()
		
		window_.reloadDev()
		
Promise = require 'avo/vendor/bluebird'

AbstractState = require 'avo/state/abstractState'
window_ = require 'avo/graphics/window'

fs = require 'avo/fs'

timing = require 'avo/timing'

require 'avo/monkeyPatches'

# #### Timing
# 
# Timing within the engine is handled in fixed steps. If the engine
# falls behind the requested ticks per second, multiple fixed steps
# will occur every tick.
# 
# * Keep track of cycles per second.
# * Keep handles for our tick loop, so we can GC it on quit.
tickInterval = null

# [Fix your timestep!](http://gafferongames.com/game-physics/fix-your-timestep/)
lastElapsed = 0
ticksPerSecondTarget = 80
tickFrequency = 1000 / ticksPerSecondTarget
tickTargetSeconds = 1 / ticksPerSecondTarget
tickRemainder = 0
timing.setTickElapsed tickTargetSeconds

originalTimestamp = Date.now()

tickCallback = ->

	try
	
		timing.setElapsed elapsed = (Date.now() - originalTimestamp) / 1000
		tickRemainder += elapsed - lastElapsed
		lastElapsed = elapsed
		
		while tickRemainder > tickTargetSeconds
			handleStateTransition()
			stateInstance?.tick()
		
			tickRemainder -= tickTargetSeconds
			
	catch error
		
		handleError error

tickInterval = window.setInterval tickCallback, tickFrequency

renderCallback = ->
	
	try
	
		stateInstance.render window_.renderer() if stateInstance?.render?
		renderInterval = window.requestAnimationFrame renderCallback

	catch error
		
		handleError error
		
renderInterval = window.requestAnimationFrame renderCallback

stateName = ''
stateTransition = null
stateInstance = null
stateInstanceCache = {}

AbstractState::transitionToState = (name, args) ->
	return if stateTransition?
	stateTransition = name: name, args: args

handleStateTransition = ->
	return unless stateTransition?
	
	{name, args} = stateTransition
	stateTransition = null
	
	stateInstance?.leave stateName
	stateInstance = null
	
	promise = Promise.asap(
	
		# If the State is already loaded and cached, fulfill the
		# initialization immediately.
		if stateInstanceCache[name]?
			true
			
		# Otherwise, instantiate and cache.
		else
			
			StateClass = require "state/#{name}"
			stateInstanceCache[name] = new StateClass()
			stateInstanceCache[name].initialize()
			
		->
			
			# Enter the state.
			Promise.asap(
				stateInstanceCache[name].enter args, stateName
				-> stateInstance = stateInstanceCache[stateName = name]
			)
	)
	promise.done() if Promise.is promise

# Read from config file.
fs.readJsonResource('/config.json').then(
	(O) -> config.mergeIn O
	->
).finally ->

	window_.instantiate()
	
	# Enter the 'initial' state. This is implemented by your game.
	AbstractState::transitionToState 'initial'
	
handleError = (error) ->
	console.log error.stack
	quit()

window.onerror = (message, filename, lineNumber, _, error) ->
	handleError error
	true

AbstractState::quit = quit = ->

	window.clearInterval tickInterval
	window.cancelAnimationFrame renderInterval
	
	window_.close()
