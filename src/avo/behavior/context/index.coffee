
defaultContext = {}

exports.defaultContext = ->

	copy = {}
	copy[k] = v for k, v of defaultContext
	copy

addDefaultKey = exports.addDefaultKey = (key, value) ->

	defaultContext[key] = value

addDefaultKey 'global', require './global'
addDefaultKey 'Rectangle', require 'avo/extension/rectangle'
addDefaultKey 'Vector', require 'avo/extension/vector'
