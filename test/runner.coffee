
global[k] = window[k] for k in [
  'beforeEach', 'describe', 'expect', 'it', 'spyOn'
]

require 'avo/monkey-patches'

# window.jasmine.DEFAULT_TIMEOUT_INTERVAL = 20000

glob = require('simple-glob');

{Window} = global.window.nwDispatcher.requireNwGui()
window_ = Window.get()

input = require 'avo/input'

input.on 'keyDown', ({keyCode, preventDefault, repeat}) ->
  return if repeat

  switch keyCode

    # F5 - Reload
    when input.Key.F5 then window_.reloadDev()

  preventDefault()

config = require 'avo/config'

config.set 'fs:srcRoot', '..'
config.set 'fs:resourcePath', './resource'

require('avo/node-webkit').bootstrap()

require module for module in glob '../src/**/*.spec.coffee'
