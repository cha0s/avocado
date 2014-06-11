
config = require 'avo/config'

module.exports = Timing = require('avo/spii') 'timing', config.get 'SPI:timing'

try
	require('./platform').augment Timing
catch error
	unless "Cannot find module './platform'" is error.message
		throw error

Timing.proxy = ->
	require("./proxies/#{proxy}").proxy Timing for proxy in [
		'TimingService'
	]

Timing.timingService = new Timing.TimingService()
