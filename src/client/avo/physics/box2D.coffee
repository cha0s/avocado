
{

  Box2D:

    Collision:
      Shapes:
        b2CircleShape: b2CircleShape
        b2PolygonShape: b2PolygonShape


    Common:
      Math:
        b2Vec2: b2Vec2

    Dynamics:
      b2BodyDef: b2BodyDef
      b2Body: b2Body
      b2ContactListener: b2ContactListener
      b2ContactFilter: b2ContactFilter
      b2FixtureDef: b2FixtureDef
      b2World: b2World

      Joints:

        b2FrictionJointDef: b2FrictionJointDef

} = require 'vendor/box2D'

Entity = require 'avo/entity'

AbstractPhysics = require './abstract'

class Box2DBody extends AbstractPhysics.Body

  @_filterCategoryBit = 0
  @_filterCategories = {}

  @_filterCategory: (category) ->

    unless @_filterCategories[category]

      @_filterCategories[category] = 1 << @_filterCategoryBit
      @_filterCategoryBit++

    @_filterCategories[category]

  constructor: (@_physics, @_entity) ->

    @_movement = [0, 0]

    bodyDef = new b2BodyDef()
    bodyDef.type = if @_entity.immovable()
      b2Body.b2_staticBody
    else
      b2Body.b2_dynamicBody

    @_body = @_physics.world().CreateBody bodyDef
    @_body.SetFixedRotation true

    for shape in @_entity.shapeList().shapes()

      fixtureDef = new b2FixtureDef()

      switch shape.type()

        when 'circle'

          circle = new b2CircleShape()
          circle.SetLocalPosition new b2Vec2(
            shape.x() / @_physics.unitRatio()
            -shape.y() / @_physics.unitRatio()
          )
          circle.SetRadius shape.radius() / @_physics.unitRatio()

          fixtureDef.shape = circle

        when 'rectangle', 'polygon'

          vertices = for vertice in shape.vertices().reverse()
            new b2Vec2(
              vertice[0] / @_physics.unitRatio()
              -vertice[1] / @_physics.unitRatio()
            )

          polygon = new b2PolygonShape()
          polygon.SetAsArray vertices, vertices.length

          fixtureDef.shape = polygon

      fixtureDef.density = 0

      if @_entity.is 'collider'

        fixtureDef.filter.categoryBits = Box2DBody._filterCategory(
          @_entity.collisionGroup()
        )

        maskBits = 0
        for group in @_entity.collidesWithGroups()
          maskBits |= Box2DBody._filterCategory group
        fixtureDef.filter.maskBits = maskBits

      fixture = @_body.CreateFixture fixtureDef
      fixture.SetUserData entity: @_entity

    @_body.SetUserData entity: @_entity

    jointDef = new b2FrictionJointDef()

    jointDef.localAnchorA.SetZero()
    jointDef.localAnchorB.SetZero()

    jointDef.bodyA = @_body
    jointDef.bodyB = @_physics._frictionBody

    jointDef.collideConnected = true

    @_joint = @_physics.world().CreateJoint jointDef

  applyForce: (vector, force) ->

    @_body.ApplyForce(
      new b2Vec2(
        vector[0] * force / @_physics.unitRatio()
        vector[1] * -force / @_physics.unitRatio()
      )
      @_body.GetWorldCenter()
    )

  applyImpulse: (vector, force) ->

    @_body.ApplyImpulse(
      new b2Vec2(
        vector[0] * force / @_physics.unitRatio()
        vector[1] * -force / @_physics.unitRatio()
      )
      @_body.GetWorldCenter()
    )

  applyMovement: (vector, force) ->

    @_movement[0] += vector[0] * force
    @_movement[1] += vector[1] * force

  forceMovement: (elapsed) ->

    @_body.ApplyImpulse(
      new b2Vec2(
        @_movement[0] / @_physics.unitRatio()
        -@_movement[1] / @_physics.unitRatio()
      )
      @_body.GetWorldCenter()
    )

  unforceMovement: (elapsed) ->

    @_body.ApplyImpulse(
      new b2Vec2(
        -@_movement[0] / @_physics.unitRatio()
        @_movement[1] / @_physics.unitRatio()
      )
      @_body.GetWorldCenter()
    )

    @_movement = [0, 0]

  internal: -> @_body

  entity: -> @_entity

  position: ->

    position = @_body.GetPosition()
    [
      position.x * @_physics.unitRatio()
      -position.y * @_physics.unitRatio()
    ]

  setPosition: (position) ->

    @_body.SetPosition new b2Vec2(
      position[0] / @_physics.unitRatio()
      -position[1] / @_physics.unitRatio()
    )

  setVelocity: (velocity) ->

    @_body.SetLinearVelocity new b2Vec2(
      velocity[0] / @_physics.unitRatio()
      -velocity[1] / @_physics.unitRatio()
    )

  velocity: ->

    velocity = @_body.GetLinearVelocity()
    [
      velocity.x * @_physics.unitRatio()
      -velocity.y * @_physics.unitRatio()
    ]

module.exports = class Box2DPhysics extends AbstractPhysics

  constructor: ->

    @_entities = {}
    @_entityContacts = {}

    @_world = new b2World(
      new b2Vec2 0, 0
      true
    )

    @_frictionBody = @_world.CreateBody new b2BodyDef()

    contactListener = new b2ContactListener

    self = this
    contactListener.BeginContact = (contact) ->

      le = ldata.entity if ldata = contact.GetFixtureA().GetUserData()
      re = rdata.entity if rdata = contact.GetFixtureB().GetUserData()

      return unless le? and re?

      (self._entityContacts[le.uuid()] ?= []).push re
      (self._entityContacts[re.uuid()] ?= []).push le

    contactListener.EndContact = (contact) ->

      le = ldata.entity if ldata = contact.GetFixtureA().GetUserData()
      re = rdata.entity if rdata = contact.GetFixtureB().GetUserData()

      return unless le? and re?

      if (la = self._entityContacts[le.uuid()])?.length
        la.splice la.indexOf(re), 1
        delete self._entityContacts[le.uuid()] if la.length is 0

      if (ra = self._entityContacts[re.uuid()])?.length
        ra.splice ra.indexOf(le), 1
        delete self._entityContacts[re.uuid()] if ra.length is 0

    @_world.SetContactListener contactListener

  addEntity: (entity) ->
    super

    @_entities[entity.uuid()] = entity
    entity.setBody new Box2DBody this, entity

  addWall: (begin, end) ->

    fixtureDef = new b2FixtureDef()
    fixtureDef.shape = new b2PolygonShape()
    fixtureDef.filter.categoryBits = -1
    fixtureDef.filter.maskBits = -1

    b2Begin = new b2Vec2(
      begin[0] / @unitRatio()
      -begin[1] / @unitRatio()
    )

    b2End = new b2Vec2(
      end[0] / @unitRatio()
      -end[1] / @unitRatio()
    )

    fixtureDef.shape.SetAsEdge b2Begin, b2End

    @_world.GetGroundBody().CreateFixture fixtureDef

  world: -> @_world

  removeEntity: (entity) ->

    if (otherEntities = @_entityContacts[entity.uuid()])?
      delete @_entityContacts[entity.uuid()]

      for otherEntity in otherEntities
        if (otherOtherEntities = @_entityContacts[otherEntity.uuid()])?
          i = otherOtherEntities.indexOf entity
          otherOtherEntities.splice i, 1 if -1 isnt i
          if 0 is otherOtherEntities.length
            delete @_entityContacts[otherEntity.uuid()]

    return unless @_entities[entity.uuid()]?
    delete @_entities[entity.uuid()]
    @_world.DestroyBody entity.body().internal()

  tick: (elapsed) ->

    for uuid, entities of @_entityContacts
      @_entities[uuid].emit 'intersected', entity for entity in entities

    entity.beforePhysicsTick elapsed for uuid, entity of @_entities

    @_world.Step elapsed / 1000, 5, 2

    entity.afterPhysicsTick elapsed for uuid, entity of @_entities

    return
