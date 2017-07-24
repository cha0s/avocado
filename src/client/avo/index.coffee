
# # Main
#
# Execution context. The "main loop" of the Avocado engine.
#

require 'avo/monkey-patches'

ErrorStackParser = require 'vendor/error-stack-parser'
Promise = require 'vendor/bluebird'

config = require 'avo/config'

core = {}

core.errorHandler = (error) ->

  console.error error.toString()
  console.error frame.source for frame in ErrorStackParser.parse error

  process?.exit error.code ? 1 unless error.skipExit

exports.start = ->

  (new Promise (resolve) -> window.onload = resolve).then(->

    require('avo/bootstrap').bootstrap core

  ).catch (error) -> core.errorHandler error

  window.onerror = (message, filename, lineNumber, _, error) ->
    core.errorHandler error
    return true
