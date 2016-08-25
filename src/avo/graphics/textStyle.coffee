
PIXI = require 'avo/vendor/pixi'

module.exports = class TextStyle

  constructor: (options) ->

    @_textStyle = new PIXI.TextStyle options

  fontFamily: -> @_textStyle.fontFamily
  setFontFamily: (fontFamily) -> @_textStyle.fontFamily = fontFamily

  fontSize: -> @_textStyle.fontSize
  setFontSize: (fontSize) -> @_textStyle.fontSize = fontSize

  fontString: -> "#{@fontFamily()} #{@fontSize()}px"
