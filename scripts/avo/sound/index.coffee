
config = require 'avo/config'

module.exports = Sound = require('avo/spii') 'sound', config.get 'SPI:sound'

try
	require('./platform').augment Sound
catch error
	unless "Cannot find module './platform'" is error.message
		throw error

Sound.proxy = ->
	require("./proxies/#{proxy}").proxy Sound for proxy in [
		'Music', 'Sample'
	]

Sound.soundService = new Sound.SoundService()
