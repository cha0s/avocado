
_ = require 'avo/vendor/underscore'

exports.instantiate = (O) ->
	[key] = _.keys O
	
	Class = require "avo/behavior/#{key}"
	instance = new Class()
	instance.fromObject O[key]
