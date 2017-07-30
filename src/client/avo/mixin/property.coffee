
FunctionExt = require 'avo/extension/function'
ObjectExt = require 'avo/extension/object'
String = require 'avo/extension/string'

module.exports = Property = (key, meta = {}) ->

  meta.set ?= (value) -> @["_#{key}"] = value
  meta.get ?= -> @["_#{key}"]
  meta.eq ?= (l, r) -> l is r

  _default = ObjectExt.deepCopy meta.default ? null

  class

    constructor: -> FunctionExt.fastApply meta.set, [_default], this

    @::[key] = meta.get

    @::[String.setterName key] = (value) ->
      oldValue = @[key]()

      FunctionExt.fastApply meta.set, arguments, this
      unless FunctionExt.fastApply meta.eq, [oldValue, value], this
        @emit? "#{key}Changed", oldValue

      return
