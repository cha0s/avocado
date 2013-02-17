
EventEmitter = require 'Utility/EventEmitter'
Mixin = require 'Utility/Mixin'

module.exports = ->
	
	socket = {}
	
	Mixin socket, EventEmitter
	
	socket
