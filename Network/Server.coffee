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

_ = require 'Utility/underscore'
Cps = require 'Timing/Cps' 
Graphics = require 'Graphics'
Main = require 'Main'
Timing = require 'Timing'

module.exports = Server = class extends Main

	constructor: (@connection) ->
		
		super
		
		@stateChange = name: 'Server/Accept', args: {}
		
		@on 'quit', =>
			
			@connection.server.close() if @connection.server?

	listen: (fn) ->
		
		switch @connection.type
			
			when 'socketIo'

				io = require('socket.io').listen @connection.server
				
				@connection.io = io
				
				for key, value of @connection.settings
				
					io.set key, value
				
				io.sockets.on 'connection', (socket) ->
					
					fn socket
					
			when 'netSocket'
				
				# This is node-specific for the time being.
				server = require('net').createServer (client) ->
					
					require('Network/NodeSocketAugmentation') client
					
					fn client
					
				server.listen @connection.listenSpec
				
				@connection.server = server
				
			when 'ipc'
				
				fn @connection.socket = @connection.ipcSocket
				
		undefined 
