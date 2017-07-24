
config = require 'avo/config'

Promise = require 'vendor/bluebird'

AbstractState = require 'avo/state/abstractState'
window_ = require 'avo/graphics/window'

fs = require 'avo/fs'

Cps = require 'avo/timing/cps'
Ticker = require 'avo/timing/ticker'
timing = require 'avo/timing'

module.exports = new class Gear

  mixins = [
    EventEmitter
  ]

  Mixin.apply [@::].concat mixins

  constructor: (frequency) ->
    mixin.call @ for mixin in mixins

    # #### Timing
    #
    # Timing within the engine is handled in fixed steps. If the engine
    # falls behind the requested ticks per second, multiple fixed steps
    # will occur every tick.
    #
    # * Keep track of cycles per second.
    # * Keep handles for our tick loop, so we can GC it on quit.
    @tickInterval = null

    # [Fix your timestep!](http://gafferongames.com/game-physics/fix-your-timestep/)
    @lastElapsed = 0
    @ticksPerSecondTarget = config.get 'timing:ticksPerSecond'
    @tickFrequency = 1000 / @ticksPerSecondTarget
    @tickTargetSeconds = 1 / @ticksPerSecondTarget
    @tickRemainder = 0
    timing.setTickElapsed @tickTargetSeconds

  tick: ->
    timing.setElapsed elapsed = (Date.now() - @originalTimestamp) / 1000

    tickTicker.tick()
    renderTicker.tick()

    sampleTicker.tick()
    adjustmentTicker.tick()

