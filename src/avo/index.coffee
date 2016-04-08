
# # Main
#
# Execution context. The "main loop" of the Avocado engine.
#

config = require 'avo/config'

Promise = require 'avo/vendor/bluebird'

AvoCanvas = require 'avo/graphics/canvas'

StateManager = require 'avo/state/manager'

require 'avo/monkey-patches'

exports.start = ->

  # Bootstrap node-webkit goodies.
  require('avo/node-webkit').bootstrap()

  stateManager = new StateManager()

  stateManager.setCanvas canvas = new AvoCanvas(
    config.get 'graphics:resolution'
    config.get 'graphics:renderer'
  )
  canvas.resize [window.innerWidth, window.innerHeight]

  stateManager.startAsync(
    config.get 'timing:ticksPerSecond'
    config.get 'timing:rendersPerSecond'
  )

  window.onresize = -> canvas.resize [window.innerWidth, window.innerHeight]

  windowPromise = new Promise (resolve) -> window.onload = resolve

  config.mergeFromFile('/config.json').then(->

    Promise.all [
      windowPromise, Promise.cast(

        try

          bootstrap = require 'avo/bootstrap'
          bootstrap.promise

        catch error
          unless error.message is "Cannot find module 'avo/bootstrap'"
            throw error
      )
    ]

  ).then ->

    # Enter the 'initial' state. This is implemented by your game.
    stateManager.emit 'transitionToState', 'avo/state/initial'

  handleError = (error) ->
    console.log error.stack

    stateManager.stopAsync()

    return quit() unless process?

    console.info "Halted... waiting for source change"

  window.onerror = (message, filename, lineNumber, _, error) ->
    handleError error
    return true

  stateManager.on 'error', handleError

  quit = -> window_.close()

  stateManager.on 'quit', quit
