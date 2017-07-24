
Promise = require 'vendor/bluebird'

ShapeList = require 'avo/physics/shape/list'

Trait = require 'avo/entity/traits/trait'

module.exports = class Shaped extends Trait

  @dependencies: [
    'corporeal'
  ]

  stateDefaults: ->

    shapeList:
      shapes: []

  constructor: ->
    super

    @_shapeList = null

  initialize: ->
    self = this

    Promise.asap(
      (new ShapeList()).fromObject(@state.shapeList)
      (_shapeList) ->
        self._shapeList = _shapeList

        self.entity.emit 'shapeListChanged'

        _shapeList.on 'aabbChanged', -> self.entity.emit 'aabbChanged'

        self.entity.emit 'aabbChanged'
    )

  properties: ->

    hasShadow: {}

  values: ->

    aabb: -> @_shapeList.aabb()

    intersects: (entity) -> @entity.shapeList().intersects entity.shapeList()

    shapeList: -> @_shapeList

  signals: ->

    traitsChanged: ->

      @_snapPosition()
      @_snapRotation()

    positionChanged: -> @_snapPosition()

    rotationChanged: ->  @_snapRotation()

  _snapPosition: -> @_shapeList.setPosition @entity.position()

  _snapRotation: -> @_shapeList.setRotation @entity.rotation()
