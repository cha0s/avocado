
timing = require 'avo/timing'

_ = require 'avo/vendor/underscore'
EventEmitter = require './eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require './index'
Property = require './property'
Promise = require 'avo/vendor/bluebird'
String = require 'avo/extension/string'
Ticker = require 'avo/timing/ticker'
Transition = require './transition'

Modulator =

  Flat: ->
    (location) -> .5

  Linear: ->
    (location) -> location

  Random: ({variance} = {}) ->

    variance ?= .4

    (location) ->
      Math.abs((Math.random() * (variance + variance) - variance)) % 1

  Sine: ->
    (location) -> .5 * (1 + Math.sin location * Math.PI * 2)

ModulatedProperty = class

  mixins = [
    EventEmitter
    Property 'frequency', default: 0
    Property 'location', default: 0
    Property 'magnitude', default: 0
    Transition
  ]

  constructor: (
    @_object, @_key
    {frequency, location, magnitude, median, modulators}
  ) ->

    modulators = [Modulator.Linear] unless modulators?
    modulators = [modulators] unless _.isArray modulators

    @_median = median

    mixin.call this for mixin in mixins

    @on 'magnitudeChanged', => @_magnitude2 = @magnitude() * 2

    @setFrequency frequency
    @setLocation location ? 0
    @setMagnitude magnitude

    @_min = @_median - magnitude if @_median?

    modulatorFunction = (modulator) ->

      if _.isString modulator

        if Modulator[modulator]?
          Modulator[modulator]
        else
          Modulator.Linear
      else

        if _.isFunction modulator
          modulator
        else
          Modulator.Linear

    @_modulators = for modulator in modulators

      if _.isObject modulator

        if modulator.f?

          modulatorFunction(modulator.f) modulator

        else

          [key] = Object.keys modulator
          modulatorFunction(key) modulator[key]

      else

        modulatorFunction(modulator)()

    @_setKey = String.setterName @_key

    @_transitions = []

  FunctionExt.fastApply Mixin, [@::].concat mixins

  tick: (elapsed) ->

    transition.tick elapsed for transition in @_transitions

    frequency = @frequency()
    location = @location()

    location += elapsed
    if location > frequency
      location -= frequency

    @setLocation location

    min = if @_median?
      @_min
    else
      @_object[@_key]()

    value = _.reduce(
      @_modulators
      (l, r) -> l + r location / frequency
      0
    ) / @_modulators.length

    @_object[@_setKey] min + value * @_magnitude2

  transition: ->

    transition = FunctionExt.fastApply(
      Transition::transition, arguments, this
    )

    @_transitions.push transition

    transition.promise.then =>

      @_transitions.splice(
        @_transitions.indexOf transition
        1
      )

    transition

LfoResult = class

  constructor: (object, properties, @_duration = 0) ->

    @_elapsed = 0
    @_isRunning = false
    @_object = {}
    @_properties = {}

    @start()

    @_deferred = Promise.defer()
    @promise = @_deferred.promise

    for key, spec of properties

      spec.frequency ?= @_duration

      @_properties[key] = new ModulatedProperty object, key, spec

  property: (key) -> @_properties[key]

  start: ->

    @_elapsed = 0
    @_isRunning = true

  stop: -> @_isRunning = false

  tick: (elapsed) ->
    return unless @_isRunning

    finished = false

    if @_duration > 0

      if @_duration <= (@_elapsed += elapsed)

        finished = true

        elapsed = @_elapsed - @_duration
        @_elapsed = @_duration

    property.tick elapsed for key, property of @_properties

    if @_duration > 0

#      @_deferred.progress [@_elapsed, @_duration]

      if finished
        @_deferred.resolve()
        @stop()

    return

module.exports = class

  lfo: (properties, duration) ->

    new LfoResult @, properties, duration
