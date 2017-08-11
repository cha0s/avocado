
FunctionExt = require 'avo/extension/function'
ObjectExt = require 'avo/extension/object'
String = require 'avo/extension/string'

internal = ObjectExt.internal()

module.exports = (key, meta = {}) ->

  meta.set ?= (value) -> internal(@)["_#{key}"] = value
  meta.get ?= -> internal(@)["_#{key}"]
  meta.eq ?= (l, r) -> l is r

  if meta.default is null
    _default = null
  else if not meta.default?
    _default = undefined
  else
    _default = ObjectExt.deepCopy meta.default

  class Property

    constructor: ->
      unless _default is undefined
        FunctionExt.fastApply meta.set, [_default], this

    @::[key] = meta.get

    @::[String.setterName key] = (value) ->
      oldValue = @[key]()

      FunctionExt.fastApply meta.set, arguments, this
      unless FunctionExt.fastApply meta.eq, [oldValue, value], this
        @emit? "#{key}Changed", oldValue, value

      return
