
module.exports = class RingBuffer

  constructor: (@_size) ->

    @_buffer = new Array @_size
    @_caret = 0

  store: (value) ->

    @_buffer[@_caret++] = value
    @_caret %= @_size
