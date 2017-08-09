
Mixin = require 'avo/mixin'

BehaviorItem = require './behaviorItem'
Invocation = require './invocation'

module.exports = Mixin.toClass [

  Invocation

], class Value extends BehaviorItem

  get: (context) -> @invoke context
