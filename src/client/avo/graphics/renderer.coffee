
PIXI = require 'vendor/pixi'

module.exports = class Renderer

  constructor: (size, type) ->

    @_renderer = switch type

      when 'auto'
        PIXI.autoDetectRenderer size[0], size[1], transparent: true

      when 'canvas'
        new PIXI.CanvasRenderer size[0], size[1], transparent: true

      when 'webgl'
        new PIXI.WebGLRenderer size[0], size[1], transparent: true

  element: -> @_renderer.view

  render: (item, target, clear) -> @_renderer.render item.internal(), target, clear

  renderer: -> @_renderer

  resize: (size) -> @_renderer.resize size[0], size[1]

  height: -> @_renderer.view.height
  width: -> @_renderer.view.width
  size: -> [@_renderer.view.width, @_renderer.view.height]
