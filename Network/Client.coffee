# **Main** implements the main engine loop. This class does everything
# you'd expect in a game loop: user input polling, timing, updating the game
# state (called *tick*ing) and rendering the game state.
#
# Also, States are managed here; instantiated as needed, and entered and left
# as requested.
#
# Subclass this to implement platform-specific functionality.
#
# Emits:
# 
# * <pre>error: When an error was encountered.</pre>
# * <pre>quit:  When the engine is shutting down.</pre>
#

Cps = require 'Timing/Cps' 
Graphics = require 'Graphics'
jsuri = require 'Utility/jsuri'
Main = require 'Main'
Timing = require 'Timing'
upon = require 'Utility/upon'

module.exports = Client = class extends Main
	
	# State implementations should add their class to this map.
	@States = {}

	constructor: (@connection) ->
		
		super
		
		# Keep a back buffer to receive all rendering from the current State.
		@backBuffer = new Graphics.Image [1280, 720]
		
		# Keep a count of the render operations performed per second.
		@rendersPerSecond = new Cps()
		
		# Keep count of render frequency in milliseconds.
		@renderFrequency = 1000 / Timing.rendersPerSecondTarget
		
		# Keep render loop, so we can GC them on
		# quit.
		@renderInterval = null
		
		# Record of connected clients, including this client. Keyed by
		# connection ID.
		@clients = {}
		
		@stateChange = name: 'Client/Initial', args: {}
		
	connect: ->
		
		defer = upon.defer()
		
		uri = jsuri.Uri @connection.url
		
		socketIo = (url) =>
			
			socket = if io?
				io.connect url
			else
				require('socket.io-client').connect url
				
			socket.on 'connect', ->
				
				defer.resolve socket
				
			@disconnect = -> socket.disconnect()
		
		switch uri.protocol()
			
			# 'http://example.com'
			# 'ws://example.com'
			when 'http', 'ws'
				
				uri.protocol 'http'
				socketIo uri.toString()
				
			# 'https://example.com'
			# 'wss://example.com'
			when 'https', 'wss'
				
				uri.protocol 'https'
				socketIo uri.toString()
				
			# 'tcp://example.com:13337'
			when 'tcp'
				
				client = require('net').connect
					host: uri.host()
					port: uri.port()
				
				require('Network/NodeSocketAugmentation') client
				
				defer.resolve client
				
			# 'unix:///tmp/avocado.sock'
			when 'unix'
				
				client = require('net').connect uri.path()
				
				require('Network/NodeSocketAugmentation') client
				
				defer.resolve client
				
			# 'ipc://'
			when 'ipc'
				
				defer.resolve @connection.ipcSocket
		
		defer.promise
	
	disconnect: ->
		
	begin: ->
		
		super
		
		# Render loop.
		@renderInterval = setInterval(
			=>
				try
					@render()
				catch error
					@emit 'error', error
			@renderFrequency
		)
	
	render: ->
		
		# Let the State do rendering.
		rectangles = @stateObject?.render @backBuffer
		if rectangles?.length > 0
			
			@emit 'render', @backBuffer, rectangles
		
		# Track the renders per second.
		@rendersPerSecond.tick()
		
	quit: ->
		
		# GC our render loop handle.
		clearInterval @renderInterval
		
		super
