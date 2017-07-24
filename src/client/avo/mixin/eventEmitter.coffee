# **EventEmitter** is a mixin which lends the ability to emit events and
# manage the registration of listeners who listen for the emission of the
# events.

# analytics = require 'avo/analytics'

_ = require 'vendor/underscore'
FunctionExt = require 'avo/extension/function'
Mixin = require './index'

module.exports = EventEmitter = class

  # Make space for the events and event emitters.
  constructor: ->

    @_events = {}
    @_namespaces = {}

  # Helper function for **on** and **off**. Parse the incoming (possibly)
  # namespaced event name, and return an object.
  parseEventName = (name) ->

    # Get the namespace, if any.
    if -1 != index = name.indexOf '.'

      namespace = name.substr(index + 1)
      name = name.substr(0, index)

    else
      namespace = ''

    namespace: namespace
    event: name

  # Add listeners to an object. *eventName* is a (possibly) namespaced event
  # to listen for. *f* is a function to be called when the event fires, and
  # *that*, if specified, is the 'this' variable in the callback. 'this'
  # defaults to the object upon which the event listener is registered.
  on: (eventNamesOrEventName, f, that = null) ->

    eventNames = if _.isArray eventNamesOrEventName
      eventNamesOrEventName
    else
      [eventNamesOrEventName]


    f.__once = false
    bound = f.bind that
    bound.__that = that
    (f.__bound ?= []).push bound

    for eventName in eventNames
      info = parseEventName eventName

      f.__event = info.event
      (@_events[info.event] ?= []).push f

      f.__namespace = info.namespace
      ((@_namespaces[info.namespace] ?= {})[info.event] ?= []).push f

    return

  once: (eventName, f, that = null) ->
    @on eventName, f, that

    info = parseEventName eventName
    @_events[info.event][@_events[info.event].length - 1].__once = true

    return

  # Remove listeners from an object.
  #
  # There are four ways to use **EventEmitter**.off:
  #
  # 1. You can call <code>object.off 'eventName', function</code> where
  # *function* is a function previously attached with <code>object.on
  # eventName, function</code>. If the function was never registered
  # against this event, nothing happens.
  #
  # 2. You can call <code>object.off 'eventName.namespace'</code> where
  # *namespace* is a user-defined namespace. If no listener was registered
  # under the current namespaced event, nothing happens.
  #
  # 3. You can call <code>object.off '.namespace'</code> where
  # *namespace* is a user-defined namespace. If no listener was registered
  # under the current namespace, nothing happens.
  #
  # 4. You can call <code>object.off 'eventName'</code>. This is generally
  # undesirable, as Avocado registers event listeners against some built-in
  # objects, and they can be easily be accidentally removed with this
  # method. ***Use caution.***
  off: (eventName, f) ->
    info = parseEventName eventName

    # If we're given the function, our job is easy.
    if 'function' is typeof f
      return if not @_events[info.event]?

      if -1 isnt (index = @_events[info.event].indexOf f)
        @_events[info.event].splice index, 1

      if -1 isnt (index = @_namespaces[info.namespace][info.event].indexOf f)
        @_namespaces[info.namespace][info.event].splice index, 1

      return

    # No namespace? Remove every matching event.
    if '' is info.namespace

      delete @_events[info.event]
      for namespace, events of @_namespaces
        delete events[info.event]

      return

    # Namespaced event? Remove it.
    if info.event
      return unless (events = @_namespaces[info.namespace])?

      for f in events[info.event]
        delete events[info.event]
        if (index = @_events[info.event].indexOf f)?
          @_events[info.event].splice index, 1

      return

    # Only a namespace? Remove all events associated with it.
    for event, fns of @_namespaces[info.namespace] ? {}
      for f in fns
        if (index = @_events[event].indexOf f)?
          @_events[event].splice index, 1
    delete @_namespaces[info.namespace]

    return

  # Notify ALL the listeners!
  emit: (name) ->
    candidates = (@_events[name] ? []).concat @_events['*'] ? []
    return unless candidates

    # analytics.tally "eventEmitter:#{name}"

    for f in candidates
      @off "#{name}.#{f.__namespace}", f if f.__once

      offset = if f.__event isnt '*' then 1 else 0

      for bound in f.__bound

        # Fast path...
        if arguments.length is offset
          bound()
        else if arguments.length is offset + 1
          bound arguments[offset]
        else if arguments.length is offset + 2
          bound arguments[offset], arguments[offset + 1]
        else if arguments.length is offset + 3
          bound arguments[offset], arguments[offset + 1], arguments[offset + 2]
        else if arguments.length is offset + 4
          bound arguments[offset], arguments[offset + 1], arguments[offset + 2], arguments[offset + 3]
        else if arguments.length is offset + 5
          bound arguments[offset], arguments[offset + 1], arguments[offset + 2], arguments[offset + 3], arguments[offset + 4]
        else
          if offset is 0
            bound.apply bound.__that, arguments
          else
            bound.apply bound.__that, (arg for arg, i in arguments when i > offset)

    return

EventEmitter.Mixin = (O) -> Mixin O, EventEmitter
