_ = require 'avo/vendor/underscore'
Promise = require 'avo/vendor/bluebird'

module.exports = class

  # Extend the state with defaults. Make sure you call from children!
  constructor: (@entity, state = {}) ->

    unless _.isObject defaults = @stateDefaults()
      throw new Error "State defaults must be an object."

    @state = _.defaults state, defaults

    # Cache all the invocations.
    this["_#{key}"] = this[key]?() for key in [
      'handler', 'hooks', 'signals', 'actions', 'values', 'properties'
    ]

    @_stateDefaults = @stateDefaults()

  # Extend with your state defaults.
  stateDefaults: -> {}

  # Emit the trait as a JSON representation.
  toJSON: ->

    state = {}
    stateDefaults = JSON.parse JSON.stringify @_stateDefaults

    for k, v of _.defaults @state, stateDefaults
      if JSON.stringify(v) isnt JSON.stringify(stateDefaults[k])
        state[k] = v

    O = {}
    O.type = @type
    O.state = state unless _.isEmpty state
    O

  hooks: -> {}

  signals: -> {}

  actions: -> {}

  values: -> {}

  properties: -> {}

  initialize: ->

  removeTrait: ->

  ephemeral: -> false
