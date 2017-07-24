
Promise = require 'vendor/bluebird'

Trait = require 'avo/entity/traits/trait'

module.exports = class Shaped extends Trait

  @dependencies: [
    'corporeal'
  ]

  constructor: ->
    super

    Container = require 'avo/graphics/container'
    Primitives = require 'avo/graphics/primitives'

    @_container = new Container()
    @_primitives = new Primitives()

  signals: ->

  signals: ->

    addToLocalContainer: (localContainer) ->

      localContainer.addChild @_container()

    shapeListChanged: ->

      self = this

      color = require 'avo/graphics/color'

      shapeList = @entity.shapeList()

      shapeList.on 'positionChanged', ->

        self._container.setPosition shapeList.positionWithOrigin()

      shapeList.on 'aabbChanged', ->

        self._primitives.clear()

        self._primitives.drawRectangle(
          Rectangle.translated(
            shapeList.aabb()
            Vector.scale shapeList.positionWithOrigin(), -1
          )
          Primitives.LineStyle color 255, 0, 255
        )

      shapeList.on 'shapesChanged', ->

        self._container.removeAllChildren()

        self._container.addChild self._primitives

        for shape in shapeList.shapes()

          self._container.addChild shape.primitives()
