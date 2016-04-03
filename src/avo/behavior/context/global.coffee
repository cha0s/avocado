
Promise = require 'avo/vendor/bluebird'

exports.randomNumber = (min, max, floor = true) ->

  mag = Math.random() * (max - min)
  mag = Math.floor mag if floor
  min + mag

exports.rectangle = (x, y, w, h) -> [x, y, w, h]
exports.vector = (x, y) -> [x, y]

exports.waitMs = (ms, state) ->

  deferred = Promise.defer()

  state.setPromise deferred.promise

  waited = 0
  state.setTicker (elapsed) -> deferred.resolve() if (waited += elapsed) >= ms
