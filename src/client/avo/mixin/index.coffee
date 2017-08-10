
FunctionExt = require 'avo/extension/function'

exports.raw = (O, mixins) ->

  O[key] ?= mixin::[key] for own key of mixin.prototype for mixin in mixins
  return

exports.toClass = (mixins, Class_) ->

  # Copy mixin prototypes.
  exports.raw Class_.prototype, mixins

  # The equivalent of adding `mixin.call this for mixin in mixins` at the top
  # of the constructor. This is done in such a funky way using a literal
  # Function object so that the resulting mixed class has the same name as the
  # source class. That's literally the only reason why.
  F = (new Function(
    'mixins', 'C'
    """
return function #{Class_.name ? 'Mixed'}() {
  for (var i in mixins) { mixins[i].call(this); }

  C.apply(this, arguments);
};
"""
  )) mixins, Class_

  # Not inheritance. Proxying.
  F.prototype = Class_.prototype
  F::constructor = F

  # Copy over static methods too.
  F[key] = Class_[key] for own key of Class_

  return F
