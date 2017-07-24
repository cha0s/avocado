
Entity = require 'avo/entity'

Vector = require 'avo/extension/vector'

AbstractPhysics = require './abstract'

class DummyBody extends AbstractPhysics.Body

  constructor: (physics, entity) ->
    @_force = [0, 0]
    @_tickForce = [0, 0]
    @_velocity = [0, 0]

  applyForce: (vector, force) -> @_force = Vector.scale(
    Vector.add vector, @_force
    force
  )

  applyImpulse: (vector, force) -> @_velocity = Vector.scale(
    Vector.add vector, @_velocity
    force
  )

  clearForces: ->
    @_force = [0, 0]
    @_tickForce = [0, 0]

  internal: ->

  position: -> @_position

  setPosition: (@_position) ->

  setVelocity: (@_velocity) ->

  tick: (elapsed) ->

    @_velocity = Vector.add @_velocity, Vector.scale @_force, elapsed / 1000
    @_position = Vector.add(
      Vector.add @_position, Vector.scale @_tickForce, elapsed / 1000
      @_velocity
    )

  velocity: -> @_velocity

module.exports = class DummyPhysics extends AbstractPhysics

  constructor: ->

    @_bodies = []
    @_entities = []

  addEntity: (entity) ->
    super

    @_entities.push entity

    body = new DummyBody this, entity
    entity.setBody body
    @_bodies.push body

  addWall: (begin, end) ->

  removeEntity: (entity) ->

    @_entities.splice @_entities.indexOf(entity), 1

  tick: (elapsed) ->

    dampening = 80

    fraction = elapsed / 1000
    rdamp = (100 - dampening) / 100
    k = rdamp / fraction

    entity.beforePhysicsTick() for entity in @_entities

    for body in @_bodies
      body.tick elapsed
      body.setVelocity Vector.scale body.velocity(), k
      body.clearForces()

    entity.afterPhysicsTick() for entity in @_entities

    return
