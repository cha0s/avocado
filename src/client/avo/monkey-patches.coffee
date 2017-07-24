
_ = require 'vendor/underscore'
Promise = require 'vendor/bluebird'

config = require 'avo/config'

# Monkey patches for nw.js
require('avo/node-webkit').monkeyPatches()

# Much more debugging information for promises.

Promise.longStackTraces() if config.get 'promises:longStackTraces'

# ## Promise#asap

# * (any) `promiseOrValue` - Either a promise or a scalar value.
# * (function) `fulfilled` - Fulfillment callback, called with the final value.
# * (function) `rejected` - Rejection callback, called with any error.

# *Register callbacks to be called ASAP -- in the case of a promise, as soon as
# the promise is resolved, otherwise immediately.*

Promise.asap = (promiseOrValue, fulfilled, rejected) ->

  if Promise.is promiseOrValue
    return promiseOrValue.then(fulfilled).catch rejected

  try
    fulfilled? promiseOrValue
  catch error
    if rejected?
      rejected error
    else
      throw error

# ## Promise#allAsap

# * (any Array) `promisesOrValues` - Any mix of promises or scalar values.
# * (function) `fulfilled` - Fulfillment callback, called with the final values.
# * (function) `rejected` - Rejection callback, called with any error.

# *Register callbacks to be called ASAP -- in the case of a promise, as soon as
# the promise is resolved, otherwise immediately.*

Promise.allAsap = (promisesOrValues, fulfilled, rejected) ->

  if (promises = _.filter(
    promisesOrValues, (promiseOrValue) -> Promise.is promiseOrValue
  )).length

    return Promise.all(promises).then((values) ->
      fulfilled? values
    ).catch rejected

  try
    fulfilled? promisesOrValues
  catch error
    if rejected?
      rejected error
    else
      throw error
