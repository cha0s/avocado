
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

class Color

  mixins = [
    Property 'red', 0
    Property 'green', 0
    Property 'blue', 0
    Property 'alpha', 1
  ]

  constructor: (r = 255, g = 0, b = 255, a = 1) ->
    mixin.call @ for mixin in mixins

    @setRed r
    @setGreen g
    @setBlue b
    @setAlpha a

  toCss: -> "rgba(#{@red()}, #{@green()}, #{@blue()}, #{@alpha()})"

  toInteger: -> (@red() << 16) | (@green() << 8) | @blue()

  FunctionExt.fastApply Mixin, [@::].concat mixins

color = module.exports = (r, g, b, a) -> new Color r, g, b, a

color.fromCss = (css) ->

  if '#'.charCodeAt(0) is css.charCodeAt(0)

    hex = css.substr 1
    hex = hex.split('').map((c) -> c + c).join '' if hex.length is 3

    r = hex.substr 0, 2
    g = hex.substr 2, 2
    b = hex.substr 4, 2

    color parseInt(r, 16), parseInt(g, 16), parseInt(b, 16)

  else

    colors = css.replace(/\s/g, '').match(/rgba?\((.*)\)/)[1].split ','

    color colors[0], colors[1], colors[2], colors[3] ? 1

color.fromInteger = (integer) ->

  color(
    (integer >> 16 & 0xFF)
    (integer >> 8 & 0xFF)
    integer & 0xFF
  )
