
# # Main
#
# Execution context. The "main loop" of the Avocado engine.
#

config = require 'avo/config'

Promise = require 'avo/vendor/bluebird'

window_ = require 'avo/graphics/window'

fs = require 'avo/fs'

Cps = require 'avo/timing/cps'
StateManager = require 'avo/state/manager'
Ticker = require 'avo/timing/ticker'

require 'avo/monkey-patches'

# Bootstrap node-webkit goodies.
require('avo/node-webkit').bootstrap()

# #### Timing
#
# Timing within the engine is handled in fixed steps. If the engine
# falls behind the requested ticks per second, multiple fixed steps
# will occur every tick.
#
# * Keep track of cycles per second.

stateManager = new StateManager()

tickCps = new Cps()
renderCps = new Cps()

renderCallback = ->

  try

    stateManager.render window_.renderer()
    renderCps.tick()

  catch error

    handleError error

originalRendersPerSecond = rendersPerSecond = config.get 'timing:rendersPerSecond'
renderTicker = new Ticker 1000 / rendersPerSecond
renderTicker.on 'tick', renderCallback

originalTicksPerSecond = ticksPerSecond = config.get 'timing:ticksPerSecond'

renderSamples = []
tickSamples = []

adjustmentTicker = new Ticker 1000
adjustmentTicker.on 'tick', ->

  renderSamples = renderSamples.filter (e) -> !!e

  actualRenderCps = renderSamples.reduce ((l, r) -> l + r), 0
  actualRenderCps /= renderSamples.length
  renderSamples = []

  if actualRenderCps < rendersPerSecond * .75
    renderTicker.setFrequency 1000 / (rendersPerSecond *= .75)

  else
    if rendersPerSecond * 1.25 <= originalRendersPerSecond
      renderTicker.setFrequency 1000 / (rendersPerSecond *= 1.25)
    else
      renderTicker.setFrequency 1000 / originalRendersPerSecond

  actualTickCps = tickSamples.reduce ((l, r) -> l + r), 0
  actualTickCps /= tickSamples.length
  tickSamples = []

sampleTicker = new Ticker 125
sampleTicker.on 'tick', ->
  renderSamples.push renderCps.count()
  tickSamples.push tickCps.count()

previous = Date.now()

dispatcher = ->

  now = Date.now()
  elapsed = now - previous
  previous = now

  try

    stateManager.tick elapsed
    tickCps.tick()

  catch error

    handleError error

  renderTicker.tick elapsed

  sampleTicker.tick elapsed
  adjustmentTicker.tick elapsed

# Ideal tick ms, but not necessarily real.
ticksPerSecondTarget = config.get 'timing:ticksPerSecond'
dispatcherInterval = window.setInterval dispatcher, 1000 / ticksPerSecondTarget

# Read from config file.
fs.readJsonResource('/config.json').then(
  (O) -> config.mergeIn O
  ->
).then(
  window_.instantiate()
).finally ->

  bootstrapPromise = try

    bootstrap = require 'avo/bootstrap'
    bootstrap.promise

  catch error

    unless error.message is "Cannot find module 'avo/bootstrap'"
      throw error

    null

  Promise.asap bootstrapPromise, ->

    # Enter the 'initial' state. This is implemented by your game.
    stateManager.emit 'transitionToState', 'avo/state/initial'

handleError = (error) ->
  console.log error.stack

  if process?

    halt()
    console.info "Halted... waiting for source change"

  else

    quit()

window.onerror = (message, filename, lineNumber, _, error) ->
  handleError error
  true

stateManager.on 'error', handleError

halt = ->

  window.clearInterval dispatcherInterval

quit = ->
  halt()

  console.log require('avo/analytics').reportData()

  window_.close()

stateManager.on 'quit', quit
