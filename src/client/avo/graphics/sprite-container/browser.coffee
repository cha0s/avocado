
PIXI = require 'vendor/pixi'

Container = require 'avo/graphics/container'

module.exports = class SpriteContainer extends Container

  constructor: -> @_container = new PIXI.particles.ParticleContainer()
