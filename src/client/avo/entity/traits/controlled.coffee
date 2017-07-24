
Promise = require 'vendor/bluebird'

Invocation = require 'avo/behavior/invocation'

Trait = require 'avo/entity/traits/trait'

module.exports = class Controlled extends Trait

  constructor: ->
    super

    @_controlLock = false
    @_input = null
    @_invocationState = null

  actions: ->

    acceptControl: (@_input) ->
      # @_input.off '.controlled'

      # @_input.on 'use.controlled', ->
      #   return if @_invocationState?
      #   return unless @entity.is 'carrying'

      #   @entity.useActiveItem @_invocationState = new Invocation.State()
      #   Promise.asap @_invocationState.promise(), => @_invocationState = null

      # , this

  handler: ->

    ticker: (elapsed) ->

      @_invocationState?.tick elapsed

      @entity.move? @_input.unitMovement() if @_input and not @_controlLock
