
EventEmitter = require 'avo/mixin/eventEmitter'
Mixin = require 'avo/mixin'

analytics = require 'avo/analytics'

isDebugging = false

Mixin exports, EventEmitter
EventEmitter.call exports

exports.setIsDebugging = (isDebugging_) ->

  wasDebugging = isDebugging
  isDebugging = isDebugging_

  @emit 'isDebuggingChanged', wasDebugging

exports.isDebugging = -> isDebugging

for forward in [
  'get'
  'has'
]
  do (forward) -> exports[forward] = ->
    args = (arg for arg in arguments)
    key = "debug:#{args.shift()}"
    analytics[forward].apply analytics, [key].concat args

for forward in [
  'getOrCreate'
  'set'
  'tally'
]

  do (forward) -> exports[forward] = (key, value) ->
    qualifiedKey = "debug:#{key}"
    had = @has key
    oldValue = analytics.get qualifiedKey
    value = analytics[forward] qualifiedKey, value
    @emit 'variableCreated', key, value unless had
    @emit 'variableChanged', key, oldValue unless oldValue is value
    return value
