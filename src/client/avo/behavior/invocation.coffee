
FunctionExt = require 'avo/extension/function'
Promise = require 'vendor/bluebird'

Behavior = require './index'
BehaviorItem = require './behaviorItem'

module.exports = class Invocation extends BehaviorItem

  class @State

    constructor: ->

      @_cleanup = null
      @_promise = null
      @_ticker = null

    cleanUp: -> @_cleanup?()
    setCleanup: (@_cleanup) ->

    promise: -> @_promise
    setPromise: (@_promise) ->

    tick: (ms) -> @_ticker? ms
    setTicker: (@_ticker) ->

  constructor: ->

    @_key = ''
    @_selector = []
    @_args = []

  fromObject: (O) ->

    [@_key, @_selector...] = O.selector.split ':'

    Promise.allAsap(
      args.map((arg) -> Behavior.instantiate arg) for args in O.args ? []
      (@_args) =>

        this
    )

  invoke: (context, state) ->
    return unless context?
    return unless (O = context[@_key])?

    argIndex = selectorIndex = 0
    holder = context

    do walk = =>
      return O if 'function' isnt typeof O

      args = (arg.get context for arg in @_args[argIndex] ? []) ? []
      args.push state if selectorIndex is @_selector.length

      O = FunctionExt.fastApply O, args, holder

    while selectorIndex < @_selector.length
      O = O[@_selector[selectorIndex++]]
      argIndex++
      holder = walk()

    return O

  toJSON: -> v:

    selector: [@_key].concat(@_selector).join ':'
    args: @_args.map (args) -> args.map (arg) -> arg.toJSON()
