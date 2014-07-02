
module.exports = config = {}

config.fs =
	
	resourcePath: 'resource'
	uiPath: 'ui'

config.graphics =
	
	resolution: [1280, 720]
	renderer: 'auto'

config.input = 
	
	mouseMovePerSecond: 50

config.timing =
	
	ticksPerSecond: 60

if process? and process.versions['node-webkit']
	
	config.platform = 'node-webkit'
	
else

	config.platform = 'browser'

