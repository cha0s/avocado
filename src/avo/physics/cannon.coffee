
Entity = require 'avo/entity'

Vector = require 'avo/extension/vector'

AbstractPhysics = require './abstract'

CANNON = require 'avo/vendor/cannon'

class CannonBody extends AbstractPhysics.Body

  constructor: (physics, entity) ->

    shape = new CANNON.Sphere

    @_body = new CANNON.Body(
      mass: 80
    )

  applyForce: (vector, force) ->

  applyImpulse: (vector, force) ->

  clearForces: ->

  internal: ->

  position: -> @_position

  setPosition: (@_position) ->

  setVelocity: (@_velocity) ->

  tick: (elapsed) ->

  velocity: -> @_velocity

module.exports = class DummyPhysics extends AbstractPhysics

  constructor: ->

    @_bodies = []
    @_entities = []

  addEntity: (entity) ->
    super

    @_entities.push entity

    body = new CannonBody this, entity
    entity.setBody body
    @_bodies.push body

  addWall: (begin, end) ->

  removeEntity: (entity) ->

    @_entities.splice @_entities.indexOf(entity), 1

  tick: (elapsed) ->

    dampening = 80

    debug = require('avo/debug')
    fraction = elapsed / 1000
    debug.set 'fraction', fraction
    rdamp = (100 - dampening) / 100
    debug.set 'rdamp', rdamp
    k = rdamp / fraction
    debug.set 'k', k

    entity.beforePhysicsTick() for entity in @_entities

    # velocityDampener = 45 / (1000 / elapsed)
    for body in @_bodies
      body.tick elapsed
      body.setVelocity Vector.scale body.velocity(), k
      body.clearForces()

    entity.afterPhysicsTick() for entity in @_entities

    return
