
config = require 'avo/config'

module.exports = Core = require('avo/spii') 'core', config.get 'SPI:core'

try
	require('./platform').augment Core
catch error
	unless "Cannot find module './platform'" is error.message
		throw error

Core.proxy = ->
	require("./proxies/#{proxy}").proxy Core for proxy in [
		'CoreService'
	]

Core.coreService = new Core.CoreService()
