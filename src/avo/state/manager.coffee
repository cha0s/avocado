
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

    self = this

    @on 'transitionToState', (path, args = {}) ->
      self.transition = path: path, args: args, phase: 0

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
            # self.instance.on '*', self.emit, self
            self.instance.initialize()

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
