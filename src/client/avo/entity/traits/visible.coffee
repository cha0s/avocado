
Container = require 'avo/graphics/container'

Trait = require './trait'

module.exports = class Visible extends Trait

  stateDefaults: ->

    opacity: 1
    isVisible: true
    scale: [1, 1]

  constructor: ->
    super

    @_localContainer = new Container()

  properties: ->

    opacity: set: (opacity) ->
      @_localContainer.setOpacity @state.opacity = opacity

  initialize: ->

    @entity.setOpacity @state.opacity

    @entity.on 'traitsChanged', =>

      @_localContainer.removeAllChildren()

      @entity.emit 'addToLocalContainer', @_localContainer

    @_localContainer.setIsVisible @state.isVisible

  actions: ->

    setIsVisible: (isVisible) ->
      @state.isVisible = isVisible
      @_localContainer.setIsVisible isVisible

  values: ->

    localContainer: -> @_localContainer

    localRectangle: -> @_localContainer.localRectangle()

    isVisible: -> @_localContainer.isVisible()
