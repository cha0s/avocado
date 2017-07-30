
FunctionExt = require 'avo/extension/function'

# Dynamic object composition helper. Most often used in an object's constructor
# function, however *instance* can be any object instance.
module.exports = (instance, Mixins...) ->

  for Mixin in Mixins
    for own key of Mixin::
      instance[key] = Mixin::[key]

  instance

module.exports.toClass = (Class_, mixins) ->
  FunctionExt.fastApply module.exports, [Class_::].concat mixins
  return Class_
