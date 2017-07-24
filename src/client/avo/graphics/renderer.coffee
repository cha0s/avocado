
PIXI = require 'vendor/pixi'

module.exports = class Renderer

  constructor: (size, type) ->

    @_renderer = switch type

      when 'auto'
        PIXI.autoDetectRenderer size[0], size[1]

      when 'canvas'
        new PIXI.CanvasRenderer size[0], size[1], transparent: true

      when 'webgl'
        new PIXI.WebGLRenderer size[0], size[1]

  element: -> @_renderer.view

  render: (item) -> @_renderer.render item.internal()

  renderer: -> @_renderer

  height: -> @_renderer.view.height
  width: -> @_renderer.view.width
  size: -> [@_renderer.view.width, @_renderer.view.height]
