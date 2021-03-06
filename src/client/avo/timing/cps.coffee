# **Cps** is used to measure the cycles per second of a process. Avocado uses
# this class to measure the cycles per second and renders per second of the
# engine itself. If you instantiate **Cps** and call **Cps**::tick()
# every time a process runs, you can call **Cps**::count() to found how
# many times the cycle runs per second.
#
# *NOTE:* When you instantiate **Cps**, a **frequency** is specified. You
# must call **Cps**.tick() for at least **frequency** milliseconds to get
# an accurate reading. Until then, you will read 0.

Ticker = require './ticker'

module.exports = class

  # Instantiate the CPS counter. By default, it counts the cycles every 250
  # milliseconds.
  constructor: (frequency = 250) ->

    previous = Date.now()

    setInterval =>

      now = Date.now()
      elapsed = now - previous
      previous = now
      @fps = @c * (1000 / elapsed)
      @c = 0

    , frequency

    @fps = 0
    @c = 0

  # Call every time the process you want to measure runs.
  tick: -> @c++

  # Call to retrieve how many cycles the process runs per second.
  count: -> @fps
