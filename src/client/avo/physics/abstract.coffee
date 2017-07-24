
module.exports = class AbstractPhysics

  class @Body

    constructor: (@_physics, @_entity) ->

    applyForce: (vector, force) ->

    applyImpulse: (vector, force) ->

    internal: ->

    position: ->

    setPosition: (position) ->

    setVelocity: (velocity) ->

    velocity: ->

  constructor: ->

    @_unitRatio = 1

  addEntity: (entity) ->
    unless entity.is 'physical'
      throw new Error "Non-physical entity added to physics"

  addWall: (begin, end) ->

  addWalls: (vertices) ->

    for vertice, i in vertices.reverse()

      @addWall vertice, vertices[(i + 1) % vertices.length]

    return

  removeEntity: (entity) ->

  setUnitRatio: (@_unitRatio) ->
  unitRatio: -> @_unitRatio

  tick: ->
