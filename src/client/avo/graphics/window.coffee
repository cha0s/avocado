
config = require 'avo/config'

window_ = null

exports.setInstance = (w) -> window_ = w

exports.close = -> window_?.close()

exports.hide = -> window_?.hide()

exports.reload = -> window_?.reloadIgnoringCache()

exports.show = -> window_?.show()

exports.toggleFullscreen = -> window_?.toggleFullscreen()
