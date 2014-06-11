
module.exports = config = {}

require('./platform').defaults config

config.ticksPerSecondTarget = 120
config.rendersPerSecondTarget = 60

config.defaultWindowResolution = [1280, 720]

config.controls =
	
	up: 'W'
	right: 'D'
	down: 'S'
	left: 'A'
	
	pause: 'Enter'
	
	use: 'ArrowLeft'
	confirm: 'ArrowDown'
	attack: 'ArrowRight'

