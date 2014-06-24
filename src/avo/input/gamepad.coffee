
input = require './index'

# Reused code from http://www.html5rocks.com/en/tutorials/doodles/gamepad/gamepad-tester/gamepad.js

gamepads = []
previousStates = []
prevRawGamepadTypes = []
ticking = false

# Check for gamepad support.
if !!navigator.getGamepads or !!navigator.webkitGetGamepads or !!navigator.webkitGamepads
	
 	# React to the gamepad being connected.
	onGamepadConnect = (event) ->
		
		# Add the new gamepad on the list of gamepads to look after.
		gamepads.push event.gamepad
		previousStates.push gamepadState event.gamepad
		
		# Start the polling loop to monitor button changes.
		startPolling()
	
	# React to the gamepad being disconnected.
	onGamepadDisconnect = (event) ->
		
		# Remove the gamepad from the list of gamepads to monitor.
		for i of gamepads
			if gamepads[i].index is event.gamepad.index
				gamepads.splice i, 1
				gamepadState.splace i, 1
				break
		
		# If no gamepads are left, stop the polling loop.
		stopPolling() if gamepads.length is 0
		
	gamepadState = (gamepad) ->
		
		axes = {}
		axes[index] = state for index, state of gamepad.axes
		
		buttons = {}
		for index, state of gamepad.buttons
			buttons[index] = if state.value? then state.value else state
		
		axes: axes
		buttons: buttons
		gamepad: gamepad
		timestamp: gamepad.timestamp
		
	# Starts a polling loop to check for gamepad state.
	startPolling = ->
		
		# Don't accidentally start a second loop, man.
		unless ticking
			ticking = true
			tick()
	
	# Stops a polling loop by setting a flag which will prevent the next
	# requestAnimationFrame() from being scheduled.
	stopPolling = -> ticking = false

	# A function called with each requestAnimationFrame(). Polls the gamepad
	# status and schedules another poll.
	tick = ->
		pollStatus()
		scheduleNextTick()

	scheduleNextTick = ->
		
		# Only schedule the next frame if we haven't decided to stop via
		# stopPolling() before.
		if ticking
			if window.requestAnimationFrame
				window.requestAnimationFrame tick
			else if window.mozRequestAnimationFrame
				window.mozRequestAnimationFrame tick
			else window.webkitRequestAnimationFrame tick	if window.webkitRequestAnimationFrame
	
		# Note lack of setTimeout since all the browsers that support
		# Gamepad API are already supporting requestAnimationFrame().
	
	# Checks for the gamepad status. Monitors the necessary data and notices
	# the differences from previous state (buttons for Chrome/Firefox,
	# new connects/disconnects for Chrome). If differences are noticed, asks
	# to update the display accordingly. Should run as close to 60 frames per
	# second as possible.
	pollStatus = ->
		
		# Poll to see if gamepads are connected or disconnected. Necessary
		# only on Chrome.
		pollGamepads()
		for i of gamepads
			gamepad = gamepads[i]
			previousState = previousStates[i]
			
			# Don't do anything if the current timestamp is the same as previous
			# one, which means that the state of the gamepad hasn't changed.
			# This is only supported by Chrome right now, so the first check
			# makes sure we're not doing anything if the timestamps are empty
			# or undefined.
			continue if gamepad.timestamp and (gamepad.timestamp is previousState.timestamp)
			
			# Scan for changes and emit events since browsers don't seem to
			# implement their own for the time being.
			for index of previousState.buttons
				previous = previousState.buttons[index]
				state = gamepad.buttons[index]
				state = state.value if state.value?
				
				if previous isnt state
					if .2 < Math.abs state
						input.emit 'gamepadButton', button: index, state: state
			
			for index of previousState.axes
				previous = previousState.axes[index]
				state = gamepad.axes[index]
				
				if previous isnt state
					if .2 < Math.abs state
						input.emit 'gamepadAxis', axis: index, state: state
			
			previousStates[i] = gamepadState gamepad
			
		return
	
	# This function is called only on Chrome, which does not yet support
	# connection/disconnection events, but requires you to monitor
	# an array for changes.
	pollGamepads = ->
		
		# Get the array of gamepads - the first method (getGamepads)
		# is the most modern one and is supported by Firefox 28+ and
		# Chrome 35+. The second one (webkitGetGamepads) is a deprecated method
		# used by older Chrome builds.
		rawGamepads = (navigator.getGamepads and navigator.getGamepads()) or (navigator.webkitGetGamepads and navigator.webkitGetGamepads())
		if rawGamepads
			
			# We don't want to use rawGamepads coming straight from the browser,
			# since it can have "holes" (e.g. if you plug two gamepads, and then
			# unplug the first one, the remaining one will be at index [1]).
			previousStatesMap = previousStates
			gamepads = []
			previousStates = []
			
			# We only refresh the display when we detect some gamepads are new
			# or removed; we do it by comparing raw gamepad table entries to
			# "undefined."
			gamepadsChanged = false
			i = 0

			while i < rawGamepads.length
				unless typeof rawGamepads[i] is prevRawGamepadTypes[i]
					gamepadsChanged = true
					prevRawGamepadTypes[i] = typeof rawGamepads[i]
				
				if rawGamepads[i]
					gamepads.push rawGamepads[i]
					
					# Make sure previous gamepad states are not discarded.
					previousStateIndex = -1
					for previousState, index in previousStatesMap
						if previousState.gamepad is rawGamepads[i]
							previousStateIndex = index
							break
					
					if -1 isnt previousStateIndex
						previousStates.push previousStatesMap[previousStateIndex]
					else
						previousStates.push gamepadState rawGamepads[i]
				
				i++
				
		return

	# Check and see if gamepadconnected/gamepaddisconnected is supported.
	# If so, listen for those events and don't start polling until a gamepad
	# has been connected.
	if window.ongamepadconnected?

		window.addEventListener 'gamepadconnected', onGamepadConnect false
		window.addEventListener 'gamepaddisconnected', onGamepadDisconnect, false
	
	else
		
		startPolling()
