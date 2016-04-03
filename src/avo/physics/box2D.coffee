
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

} = require 'avo/vendor/box2D'

Entity = require 'avo/entity'

AbstractPhysics = require './abstract'

PixelToMeterScale = 64

contactListener = new b2ContactListener

contactListener.BeginContact = (contact) ->

  le = ldata.entity if ldata = contact.GetFixtureA().GetUserData()
  re = rdata.entity if rdata = contact.GetFixtureB().GetUserData()

  le?.emit 'intersected', re
  re?.emit 'intersected', le

class Box2DBody extends AbstractPhysics.Body

  @_filterCategoryBit = 0
  @_filterCategories = {}

  @_filterCategory: (category) ->

    unless @_filterCategories[category]

      @_filterCategories[category] = 1 << @_filterCategoryBit
      @_filterCategoryBit++

    @_filterCategories[category]

  constructor: (@_physics, @_entity) ->

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
            shape.x() / PixelToMeterScale
            -shape.y() / PixelToMeterScale
          )
          circle.SetRadius shape.radius() / PixelToMeterScale

          fixtureDef.shape = circle

        when 'rectangle', 'polygon'

          vertices = for vertice in shape.vertices().reverse()
            new b2Vec2(
              vertice[0] / PixelToMeterScale
              -vertice[1] / PixelToMeterScale
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
        vector[0] * force / PixelToMeterScale
        vector[1] * -force / PixelToMeterScale
      )
      @_body.GetWorldCenter()
    )

  applyImpulse: (vector, force) ->

    @_body.ApplyImpulse(
      new b2Vec2(
        vector[0] * force / PixelToMeterScale
        vector[1] * -force / PixelToMeterScale
      )
      @_body.GetWorldCenter()
    )

  internal: -> @_body

  entity: -> @_entity

  position: ->

    position = @_body.GetPosition()
    [
      position.x * PixelToMeterScale
      -position.y * PixelToMeterScale
    ]

  setPosition: (position) ->

    @_body.SetPosition new b2Vec2(
      position[0] / PixelToMeterScale
      -position[1] / PixelToMeterScale
    )

  setVelocity: (velocity) ->

    @_body.SetLinearVelocity new b2Vec2(
      velocity[0] / PixelToMeterScale
      -velocity[1] / PixelToMeterScale
    )

  velocity: ->

    velocity = @_body.GetLinearVelocity()
    [
      velocity.x * PixelToMeterScale
      -velocity.y * PixelToMeterScale
    ]

module.exports = class Box2DPhysics extends AbstractPhysics

  constructor: ->

    @_entities = []

    @_world = new b2World(
      new b2Vec2 0, 0
      true
    )

    @_frictionBody = @_world.CreateBody new b2BodyDef()

    @_world.SetContactListener contactListener

  addEntity: (entity) ->
    super

    @_entities.push entity
    entity.setBody new Box2DBody this, entity

  addWall: (begin, end) ->

    fixtureDef = new b2FixtureDef()
    fixtureDef.shape = new b2PolygonShape()
    fixtureDef.filter.categoryBits = -1
    fixtureDef.filter.maskBits = -1

    b2Begin = new b2Vec2(
      begin[0] / PixelToMeterScale
      -begin[1] / PixelToMeterScale
    )

    b2End = new b2Vec2(
      end[0] / PixelToMeterScale
      -end[1] / PixelToMeterScale
    )

    fixtureDef.shape.SetAsEdge b2Begin, b2End

    @_world.GetGroundBody().CreateFixture fixtureDef

  world: -> @_world

  removeEntity: (entity) ->

    return if -1 is (index = @_entities.indexOf entity)

    @_entities.splice index, 1
    @_world.DestroyBody entity.body().internal()

  unitRatio: -> 1 / 64

  tick: (elapsed) ->

    entity.beforePhysicsTick() for entity in @_entities

    @_world.Step elapsed / 1000, 5, 2

    entity.afterPhysicsTick() for entity in @_entities

    return
