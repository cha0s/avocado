
config = require 'avo/config'

exports.bootstrap = ->

  if 'node-webkit' is config.get 'platform'

    util = require 'util'

    # I am the opposite of a fan of how node-webkit hands all logging to
    # webkit.
    for type in ['error', 'info', 'log', 'warn']

      do (type) -> window.console[type] = console[type] = ->

        socket = process[if type is 'error' then 'stderr' else 'stdout']
        socket.write '[ERROR] ' if type is 'error'

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

    # Hot reload the engine when source files change.
    srcRoot = config.get 'fs:srcRoot'
    {Gaze} = require 'gaze'
    gaze = new Gaze [
      "#{srcRoot}/avocado/src/**/*.js"
      "#{srcRoot}/avocado/src/**/*.coffee"
      "#{srcRoot}/src/**/*.js"
      "#{srcRoot}/src/**/*.coffee"
      "#{srcRoot}/ui/**/*.html"
      "#{srcRoot}/ui/**/*.css"
      "#{srcRoot}/index-nw.html"
    ]

    gaze.on 'all', (event, filepath) -> gaze.close()

    require('avo/graphics/window').show()

    gaze.on 'end', -> require('avo/graphics/window').reload()

