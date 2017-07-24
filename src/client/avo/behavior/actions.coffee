
Promise = require 'vendor/bluebird'

EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

Invocation = require './invocation'
Invocations = require './invocations'

module.exports = class Actions extends Invocations

  mixins = [
    EventEmitter
  ]

  constructor: ->
    super

    mixin.call this for mixin in mixins

    @_index = 0
    @_state = null

  FunctionExt.fastApply Mixin, [@::].concat mixins

  index: -> @_index

  setIndex: (@_index) ->

  tick: (context, elapsed) ->
    return if @_invocations.length is 0
    return @_state.tick elapsed if @_state?

    # Actions execute immediately until a promise is made, or they're all
    # executed.
    while true
      @_invocations[@_index++].invoke context, @_state = new Invocation.State()

      if Promise.is @_state.promise()
        @_state.promise().then => @_prologue()
        @_state.promise().catch (error) -> throw error
        break

      @_prologue()
      break if @_index is 0

    return

  _prologue: ->
    @_state.cleanUp()
    @_state = null

    @emit 'actionsFinished' if 0 is @_index = @_index % @_invocations.length
