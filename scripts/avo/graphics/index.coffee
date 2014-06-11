
config = require 'avo/config'

module.exports = Graphics = require('avo/spii') 'graphics', config.get 'SPI:graphics'

try
	require('./platform').augment Graphics
catch error
	unless "Cannot find module './platform'" is error.message
		throw error

Graphics.proxy = ->
	require("./proxies/#{proxy}").proxy Graphics for proxy in [
		'Canvas', 'Font', 'GraphicsService', 'Image', 'Sprite', 'Window'
	]

Graphics.graphicsService = new Graphics.GraphicsService()
