
Promise = require 'vendor/bluebird'

Entity = require 'avo/entity'

Trait = require 'avo/entity/traits/trait'

module.exports = class Carrying extends Trait

  stateDefaults: ->

    activeItemIndex: 0
    activeItems: []
    bagItems: []

  constructor: ->
    super

    @_activeItems = []
    @_bagItems = []

  initialize: ->
    self = this

    allPromises = for itemType in ['activeItems', 'bagItems']

      promises = for itemdef, i in self.state[itemType]
        continue unless itemdef?
        do (i, itemType) -> Entity.load(itemdef.uri).then (item) ->
          self.entity.addChild self["_#{itemType}"][i] = item

      Promise.all promises

    Promise.all allPromises

  properties: ->

    activeItemIndex: {}

  actions: ->

    setNextActiveItemIndex: ->

      @entity.setActiveItemIndex (@entity.activeItemIndex() + 1) % 10

    setPreviousActiveItemIndex: ->

      @entity.setActiveItemIndex (@entity.activeItemIndex() + 9) % 10

    useActiveItem: (state) -> @entity.activeItem()?.use state

  values: ->

    activeItem: -> @_activeItems[@entity.activeItemIndex()]

    activeItems: -> @_activeItems


