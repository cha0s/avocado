
_ = require 'vendor/underscore'
$ = require 'vendor/jquery'
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Transition = require 'avo/mixin/transition'
window_ = require 'avo/graphics/window'

module.exports = class DomNode

  mixins = [
    EventEmitter
    Transition
  ]

  constructor: (htmlOrElement) ->
    mixin.call this for mixin in mixins

    if _.isString htmlOrElement

      @_node = window.document.createElement 'div'
      @_node.innerHTML = htmlOrElement

      @_node.style.position = 'absolute'
      @_node.style.height = '100%'
      @_node.style.width = '100%'

    else

      @_node = htmlOrElement

    @_node.$ = $(@_node)

    # Set defaults.
    @setIsSelectable false
    @setPosition [0, 0]

  FunctionExt.fastApply Mixin, [@::].concat mixins

  destroy: ->

    container = window_.container()
    container.removeChild @_node

  addClass: (classNames) -> $(@_node).addClass classNames

  css: ->

    FunctionExt.fastApply(
      @_node.$.css
      arg for arg in arguments
      @_node.$
    )

  element: -> @_node

  find: (selector) -> @_node.$.find selector

  hasClass: (className) -> @_node.$.hasClass classNames

  html: -> @_node.outerHTML

  removeClass: (classNames) -> @_node.$.removeClass classNames

  hide: -> @_node.style.display = 'none'

  show: -> @_node.style.display = 'block'

  setIsSelectable: (isSelectable) ->

    if isSelectable

      @removeClass 'unselectable'
      @_node.removeAttribute 'unselectable'
      @_node.removeAttribute 'onselectstart'

      @_node.style.cursor = 'auto'

    else

      @addClass 'unselectable'
      @_node.setAttribute 'unselectable', 'yes'
      @_node.setAttribute 'onselectstart', 'return false;'

      @_node.style.cursor = 'default'

  _parsePx: (px) ->
    parsed = px.match /^-?[0-9.]+/
    return 0 unless parsed?
    parseFloat parsed

  x: -> @_parsePx @_node.style.left
  setX: (x) -> @_node.style.left = "#{x}px"

  y: -> @_parsePx @_node.style.top
  setY: (y) -> @_node.style.top = "#{y}px"

  position: -> [@x(), @y()]
  setPosition: (position) ->
    @setX position[0]
    @setY position[1]

  opacity: -> parseInt (@_node.style.opacity or 0)

  setOpacity: (opacity) -> @_node.style.opacity = opacity

  setScale: (scale) ->

    for prefix in ['-moz-', '-ms-', '-webkit-', '-o-', '']

      @_node.style["#{prefix}transform"] = "scale(#{
        scale[0]
      }, #{
        scale[1]
      })"

      @_node.style["#{prefix}transform-origin"] = "0 0 0"
      @_node.style["#{prefix}transformOrigin"] = "0 0 0"

    return
