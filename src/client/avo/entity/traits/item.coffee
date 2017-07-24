
Promise = require 'vendor/bluebird'

Trait = require 'avo/entity/traits/trait'

Actions = require 'avo/behavior/actions'

module.exports = class Item extends Trait

  @dependencies: [
    'child'
  ]

  constructor: ->
    super

    @_useActions = new Actions()

  stateDefaults: ->

    quantity: 1
    useActions: [
    ]

  initialize: ->

    Promise.allAsap [
      @_useActions.fromObject @state.useActions
    ]

  properties: ->

    quantity: {}

  actions: ->

    use: (state) ->
      self = this

      state.setTicker (elapsed) ->
        self._useActions.tick self.entity.context(), elapsed
      state.setPromise new Promise (resolve) ->
        self._useActions.on 'actionsFinished', resolve
