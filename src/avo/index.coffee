
# # Main
#
# Execution context. The "main loop" of the Avocado engine.
#

# Bootstrap node-webkit goodies.
require('avo/node-webkit').bootstrap()

ErrorStackParser = require 'avo/vendor/error-stack-parser'
Promise = require 'avo/vendor/bluebird'

config = require 'avo/config'

AvoCanvas = require 'avo/graphics/canvas'

Input = require 'avo/input'

StateManager = require 'avo/state/manager'

require 'avo/monkey-patches'

exports.start = ->

  (stateManager = new StateManager()).setCanvas canvas = new AvoCanvas(
    config.get 'graphics:resolution'
    config.get 'graphics:renderer'
  )
  window.document.body.appendChild canvas.element()
  canvas.resize [window.innerWidth, window.innerHeight]

  stateManager.setInput input = new Input()
  input.attachListeners(
    key: true
    mouse: true
    gamepad: true
  )

  canvas.translateInput input

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

  ).then(->

    # Enter the 'initial' state. This is implemented by your game.
    stateManager.emit 'transitionToState', 'avo/state/initial'

  ).catch handleError

  handleError = (error) ->
    [type, message] = error.toString().split ':'

    errorNode = require('avo/ui/error').createNode canvas

    errorNode.find('.error-type').text type
    errorNode.find('.error-message').text message
    errorNode.find('.backtrace').append(
      require('avo/vendor/jquery')('<li />').text frame.source
    ) for frame in ErrorStackParser.parse error
    errorNode.show()

    stateManager.stopAsync()

    return quit() unless process?

    console.info "Halted... waiting for source change"

  window.onerror = (message, filename, lineNumber, _, error) ->
    handleError error
    return true

  stateManager.on 'error', handleError

  quit = ->
    stateManager.stopAsync()
    require('avo/graphics/window').close()

  stateManager.on 'quit', quit
