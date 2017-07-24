
config = require 'avo/config'

exports.monkeyPatches = ->

  return unless 'node-webkit' is config.get 'platform'

  util = require 'util'

  # I am the opposite of a fan of how node-webkit hands all logging to
  # webkit.
  for type in ['error', 'info', 'log', 'warn']

    do (type) -> window.console[type] = console[type] = ->

      socket = process[if type is 'error' then 'stderr' else 'stdout']

      socket.write switch type
        when 'error'
          '\u001b[1m\u001b[31m[ERROR]\u001b[39m\u001b[22m\t'
        when 'warn'
          '\u001b[1m\u001b[33m[WARN]\u001b[39m\u001b[22m\t'
        when 'info'
          '\u001b[1m\u001b[32m[INFO]\u001b[39m\u001b[22m\t'
        else
          ''

      for arg, i in arguments
        socket.write ' ' if i > 0
        socket.write if 'string' is typeof arg then arg else util.inspect arg

      socket.write '\n'

  # Fix PIXI and we can remove these.
  global.document = window.document
  global.navigator = window.navigator
  global.Image = window.Image
  global.HTMLImageElement = window.HTMLImageElement
  global.Float32Array = window.Float32Array
  global.Uint16Array = window.Uint16Array

exports.gaze = (paths) ->

  return unless 'node-webkit' is config.get 'platform'

  throw new Error(
    "Gazing into the abyss... (node-webkit::gaze called with no paths)"
  ) if (paths ? []).length is 0

  # Hot reload the engine when source files change.
  {Gaze} = require 'gaze'
  gaze = new Gaze paths

  gaze.on 'all', (event, filepath) -> gaze.close()

  require('avo/graphics/window').show()

  gaze.on 'end', -> require('avo/graphics/window').reload()
