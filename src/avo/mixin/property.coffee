
FunctionExt = require 'avo/extension/function'
String = require 'avo/extension/string'

module.exports = Property = (key, defaultValue, meta = {}) ->

  meta.set ?= (value) -> @["_#{key}"] = value
  meta.get ?= -> @["_#{key}"]
  meta.eq ?= (l, r) -> l is r

  class

    constructor: ->

      FunctionExt.fastApply meta.set, [defaultValue], this if defaultValue?

    @::[key] = meta.get

    @::[String.setterName key] = (value) ->
      oldValue = @[key]()

      FunctionExt.fastApply meta.set, arguments, this
      unless FunctionExt.fastApply meta.eq, [oldValue, value], this
        @emit? "#{key}Changed", oldValue

      return
