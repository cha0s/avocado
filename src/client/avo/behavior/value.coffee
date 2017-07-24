
Mixin = require 'avo/mixin'

BehaviorItem = require './behaviorItem'
Invocation = require './invocation'

module.exports = class Value extends BehaviorItem

  constructor: -> Invocation.call this

  get: (context) -> @invoke context

Mixin Value::, Invocation
