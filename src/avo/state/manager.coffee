
Promise = require 'avo/vendor/bluebird'

AbstractState = require 'avo/state/abstractState'
window_ = require 'avo/graphics/window'

fs = require 'avo/fs'

Cps = require 'avo/timing/cps'
FunctionExt = require 'avo/extension/function'
Ticker = require 'avo/timing/ticker'

Mixin = require 'avo/mixin'
EventEmitter = require 'avo/mixin/eventEmitter'

module.exports = class StateManager

  mixins = [
    EventEmitter
  ]

  FunctionExt.fastApply Mixin, [@::].concat mixins

  constructor: ->
    mixin.call @ for mixin in mixins

    @cache = {}
    @instance = null
    @path = ''
    @transition = null

    @_canvas = null
    @_dispatcherInterval = null

    @on 'transitionToState', (path, args = {}) ->
      @transition = path: path, args: args, phase: 0
    , this

  setCanvas: (@_canvas) ->

  startAsync: (tps, rps)->
    return if @_dispatcherInterval?

    originalRendersPerSecond = rendersPerSecond = rps
    originalTicksPerSecond = ticksPerSecond = tps

    renderCps = new Cps()
    renderTicker = new Ticker 1000 / rendersPerSecond
    renderTicker.on 'tick', =>

      try

        @render @_canvas.renderer()
        renderCps.tick()

      catch error

        @emit 'error', error

    renderSamples = []
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

    sampleTicker = new Ticker 125
    sampleTicker.on 'tick', -> renderSamples.push renderCps.count()

    previous = Date.now()

    dispatcher = =>

      now = Date.now()
      elapsed = now - previous
      previous = now

      try

        @tick elapsed

      catch error

        @emit 'error', error

      adjustmentTicker.tick elapsed
      renderTicker.tick elapsed
      sampleTicker.tick elapsed

    # Ideal tick ms, but not necessarily real.
    @_dispatcherInterval = window.setInterval dispatcher, 1000 / tps

  stopAsync: ->
    return unless @_dispatcherInterval?
    clearInterval @_dispatcherInterval
    @_dispatcherInterval = null

  tick: (elapsed) ->
    self = this

    return unless (transition = self.transition)?
    {path, args} = transition

    switch transition.phase

      when 0

        try

          self.instance?.leave args, path
          self.instance?.off '*'
          self.instance = null
          transition.phase = 1

        catch error

          self.emit 'error', error

      when 1

        transition.phase = 1.5

        promise = Promise.asap(

          # If the State is already loaded and cached, fulfill the
          # initialization immediately.
          if not args.purgeState and self.cache[path]?

            self.instance = self.cache[path]
            self.instance.on '*', (name, args...) -> self.emit name, args...
            undefined

          # Otherwise, instantiate and initialize.
          else

            StateClass = require path
            self.instance = self.cache[path] = new StateClass()
            self.instance.on '*', (name, args...) -> self.emit name, args...
            self.instance.initialize @_canvas

          -> transition.phase = 2
          (error) -> self.emit 'error', error
        )
        if Promise.is promise
          promise.catch (error) -> self.emit 'error', error

      when 2

        transition.phase = 2.5

        # Enter the state.
        Promise.asap(
          self.instance.enter args, self.path
          -> transition.phase = 3
          (error) -> self.emit 'error', error
        )

    @instance.tick elapsed if transition.phase is 3

  render: (renderer) -> @instance.render renderer if @transition?.phase is 3
