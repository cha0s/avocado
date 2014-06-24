
PIXI = require 'avo/vendor/pixi'

color = require './color'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
VectorMixin = require 'avo/mixin/vector'

Container = require './container'

module.exports = class SpriteContainer extends Container
	
	constructor: -> @_container = new PIXI.SpriteBatch()
