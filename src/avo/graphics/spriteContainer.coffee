
PIXI = require 'avo/vendor/pixi'

Container = require './container'

module.exports = class SpriteContainer extends Container

  constructor: -> @_container = new PIXI.SpriteBatch()
