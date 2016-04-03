
PIXI = require 'avo/vendor/pixi'

color = require 'avo/graphics/color'
Renderable = require 'avo/graphics/renderable'

module.exports = class Primitives extends Renderable

  @LineStyle: (color, thickness = 1) -> color: color, thickness: thickness

  @FillStyle: (color) -> color: color

  constructor: ->
    super

    @_graphics = new PIXI.Graphics()

  clear: -> @_graphics.clear()

  drawCircle: (position, radius, lineStyle, fillStyle) ->
    return unless lineStyle?

    @_graphics.beginFill(
      fillStyle.color.toInteger()
      fillStyle.color.alpha()
    ) if fillStyle?

    @_graphics.lineStyle(
      lineStyle.thickness
      lineStyle.color.toInteger()
      lineStyle.color.alpha()
    )

    @_graphics.drawCircle position[0], position[1], radius

    @_graphics.endFill() if fillStyle?

  drawEllipse: (dimensions, lineStyle, fillStyle) ->
    return unless lineStyle?

    @_graphics.beginFill(
      fillStyle.color.toInteger()
      fillStyle.color.alpha()
    ) if fillStyle?

    @_graphics.lineStyle(
      lineStyle.thickness
      lineStyle.color.toInteger()
      lineStyle.color.alpha()
    )

    @_graphics.drawEllipse(
      dimensions[0], dimensions[1], dimensions[2], dimensions[3]
    )

    @_graphics.endFill() if fillStyle?

  drawLine: (p1, p2, lineStyle, fillStyle) ->
    return unless lineStyle?

    @_graphics.beginFill(
      fillStyle.color.toInteger()
      fillStyle.color.alpha()
    ) if fillStyle?

    @_graphics.lineStyle(
      lineStyle.thickness
      lineStyle.color.toInteger()
      lineStyle.color.alpha()
    )

    @_graphics.moveTo p1[0], p1[1]
    @_graphics.lineTo p2[0], p2[1]

    @_graphics.endFill() if fillStyle?

  drawRectangle: (rectangle, lineStyle, fillStyle) ->
    return unless lineStyle?

    @_graphics.beginFill(
      fillStyle.color.toInteger()
      fillStyle.color.alpha()
    ) if fillStyle?

    @_graphics.lineStyle(
      lineStyle.thickness
      lineStyle.color.toInteger()
      lineStyle.color.alpha()
    )

    @_graphics.drawRect(
      rectangle[0], rectangle[1], rectangle[2], rectangle[3]
    )

    @_graphics.endFill() if fillStyle?

  internal: -> @_graphics
