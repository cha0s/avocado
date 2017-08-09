
PIXI = require 'vendor/pixi'

TextStyle = require 'avo/graphics/textStyle'

Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

Font = require './font'
Renderable = require './renderable'

module.exports = Mixin.toClass [

  Property 'fontFamily', default: 'sans-serif'
  Property 'fontSize', default: 12

], class Text extends Renderable

  constructor: (text) ->
    super

    @_style = new TextStyle(
      fontFamily: @fontFamily()
      fontSize: @fontSize()
    )

    @_text = new PIXI.Text text

    # TODO Do we still need dirty here?

    @on 'fontFamilyChanged', ->
      @_style.setFontFamily @fontFamily()
      @_text.dirty = true
    , this

    @on 'fontSizeChanged', ->
      @_style.setFontSize @fontSize()
      @_text.dirty = true
    , this

  setColor: (color) ->

    @_text.style.fill = color.toCss()
    @_text.style.stroke = color.toCss()
    @_text.dirty = true

  setFillColor: (color) ->

    @_text.style.fill = color.toCss()
    @_text.dirty = true

  setStrokeColor: (color) ->

    @_text.style.stroke = color.toCss()
    @_text.dirty = true

  setStrokeThickness: (px) ->

    @_text.style.strokeThickness = px
    @_text.dirty = true

  setText: (text) ->

    oldText = @_text.text
    return if oldText is text

    @_text.setText text

  textSize: ->

    node = Font.textNode @_text.text, @_style
    window.document.body.appendChild node
    size = [node.clientWidth, node.clientHeight]
    window.document.body.removeChild node
    return size

  internal: -> @_text
