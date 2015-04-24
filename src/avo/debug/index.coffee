
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

isDebugging = false

Mixin exports, EventEmitter
EventEmitter.call exports

exports.setIsDebugging = (isDebugging_) ->

	wasDebugging = isDebugging
	isDebugging = isDebugging_

	@emit 'isDebuggingChanged', wasDebugging

exports.isDebugging = -> isDebugging
