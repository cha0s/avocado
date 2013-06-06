
EventEmitter = require 'Mixin/EventEmitter'
Mixin = require 'Mixin/Mixin'

module.exports = ->
	
	socket = {}
	
	Mixin socket, EventEmitter
	
	socket
