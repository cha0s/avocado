
Actions = require 'avo/behavior/actions'
Routines = require 'avo/behavior/routines'

{State: InvocationState} = require 'avo/behavior/invocation'

Promise = require 'avo/vendor/bluebird'
Trait = require './trait'

module.exports = Behavioral = class extends Trait

  stateDefaults: ->

    isBehaving: true
    routineIndex: 'initial'
    routines: {}
    staticSerialActions: []
    staticParallelActions: []

  constructor: ->
    super

    @_routines = new Routines()
    @_staticSerialActions = new Actions()
    @_staticParallelActions = new Actions()
    @_staticParallelState = new InvocationState()

  _startStaticParallelActions: ->
    return unless @_staticParallelActions.count() > 0

    @_staticParallelActions.parallel @entity.context(), @_staticParallelState

    # TODO: this can probably stack overflow with an immediate result...
    Promise.asap(
      @_staticParallelState.promise()
      =>
        @_staticParallelState = new InvocationState()
        @_startStaticParallelActions()
    )

    return

  initialize: ->

    Promise.allAsap [
      @_routines.fromObject @state.routines
      @_staticSerialActions.fromObject @state.staticSerialActions
      @_staticParallelActions.fromObject @state.staticParallelActions
    ], =>

      @_startStaticParallelActions() if @state.isBehaving

  properties: ->

    isBehaving:
      set: (isBehaving) ->
        return if @state.isBehaving is isBehaving

        @_staticParallelState = new InvocationState()
        @_startStaticParallelActions() if @state.isBehaving = isBehaving

    routineIndex:

      set: (routineIndex) ->

        @state.routineIndex = routineIndex

  actions: ->

    parallel: (actions, state) -> actions.parallel @entity.context(), state

    serial: (actions, state) ->
      self = this

      state.setTicker (elapsed) -> actions.tick self.entity.context(), elapsed
      state.setPromise new Promise (resolve) ->
        actions.on 'actionsFinished', resolve

  handler: ->

    ticker: (elapsed) ->
      return unless @entity.isBehaving()

      @_routines.routine(@state.routineIndex).tick @entity.context(), elapsed
      @_staticSerialActions.tick @entity.context(), elapsed
      @_staticParallelState.tick elapsed

      return

  signals: ->

    isBehavingChanged: (isBehaving) ->

      @_startStaticParallelActions() if @state.isBehaving

    dying: -> @entity.setIsBehaving false
