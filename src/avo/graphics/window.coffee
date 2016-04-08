
config = require 'avo/config'

exports.close = ->

  if 'node-webkit' is config.get 'platform'

    {Window} = global.window.nwDispatcher.requireNwGui()
    window_ = Window.get()

    window_.close()

exports.hide = ->

  if 'node-webkit' is config.get 'platform'

    {Window} = global.window.nwDispatcher.requireNwGui()
    window_ = Window.get()

    window_.hide()

exports.show = ->

  if 'node-webkit' is config.get 'platform'

    {Window} = global.window.nwDispatcher.requireNwGui()
    window_ = Window.get()

    window_.show()
