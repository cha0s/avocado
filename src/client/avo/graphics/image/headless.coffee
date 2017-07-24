
Promise = require 'vendor/bluebird'

module.exports = class AvoImage

  @load: -> Promise.cast new AvoImage()
  @loadWithoutCache: -> Promise.cast new AvoImage()

  size: -> [0, 0]
