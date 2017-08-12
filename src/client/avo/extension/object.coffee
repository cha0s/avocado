
AvoWeakMap = require 'vendor/weak-map'

exports.deepCopy = (O) -> JSON.parse JSON.stringify O

exports.internal = (ctor = ->) ->

  map = new AvoWeakMap()

  (O) ->

    map.set O, new ctor(O) unless map.has O
    return map.get O
