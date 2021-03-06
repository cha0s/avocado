
Promise = require 'vendor/bluebird'

fs = require 'avo/fs'

window_ = require 'avo/graphics/window'

Mixin = require 'avo/mixin'
EventEmitter = require 'avo/mixin/eventEmitter'

Ticker = require 'avo/timing/ticker'

AbstractState = require './abstractState'

module.exports = Mixin.toClass [

  EventEmitter

], class StateManager

  constructor: ->

    @cache = {}
    @instance = null
    @path = ''
    @transition = null

    @_canvas = null
    @_input = null
    @_dispatcherInterval = null

    @on 'transitionToState', (path, args = {}) ->
      @transition = path: path, args: args, phase: 0
    , this

  setCanvas: (@_canvas) ->

  setInput: (@_input) ->

  startAsync: (tps, rps)->
    return if @_dispatcherInterval?

    renderTicker = new Ticker 1000 / rps
    renderTicker.on 'tick', =>

      try

        @render @_canvas.renderer()

      catch error

        @emit 'error', error

    previous = Date.now()

    dispatcher = =>

      now = Date.now()
      elapsed = now - previous
      previous = now

      try

        @tick elapsed

      catch error

        @emit 'error', error

      renderTicker.tick elapsed

    # Ideal tick ms, but not necessarily real.
    @_dispatcherInterval = window.setInterval dispatcher, 1000 / tps

  stopAsync: ->
    return unless @_dispatcherInterval?
    window.clearInterval @_dispatcherInterval
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
            self.instance.initialize(
              canvas: @_canvas
              input: @_input
            )

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
