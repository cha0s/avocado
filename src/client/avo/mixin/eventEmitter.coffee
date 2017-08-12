# **EventEmitter** is a mixin which lends the ability to emit events and
# manage the registration of listeners who listen for the emission of the
# events.

# analytics = require 'avo/analytics'

ObjectExt = require 'avo/extension/object'

internal = ObjectExt.internal class EventEmitterInternal

  class EventEmitterListener

    constructor: (@f, @that, @eventName, @namespace, @once) ->

      @bound = @f.bind @that

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
    eventName: name

  removeFunction = (listeners, f) ->

    toRemove = []

    for listener, index in listeners

      continue unless f is listener.f
      toRemove.push listener

    for listener in toRemove

      index = listeners.indexOf listener
      listeners.splice index, 1

    return

  constructor: (@mixed) ->

    @events = {}
    @namespaces = {}

  candidatesFor: (eventName) ->

    (@events[eventName] ? []).concat @events['*'] ? []

  off: (eventNames, f) ->

    eventNames = [eventNames] unless Array.isArray eventNames
    @offSingleEvent eventName, f for eventName in eventNames

    return

  offSingleEvent: (eventName, f) ->

    {eventName, namespace} = parseEventName eventName

    # If we're given the function, our job is easy.
    if 'function' is typeof f

      return if not @events[eventName]?

      removeFunction @events[eventName], f
      removeFunction @namespaces[namespace][eventName], f

      return

    # No namespace? Remove every matching event.
    if '' is namespace

      delete @events[eventName]
      delete events[eventName] for namespace, events of @namespaces

      return

    # Namespaced event? Remove it.
    if eventName

      return unless (events = @namespaces[namespace])?

      for listener in events[eventName]

        continue if -1 is index = @events[eventName].indexOf listener
        @events[eventName].splice index, 1

      delete events[eventName]

      return

    # Only a namespace? Remove all events associated with it.
    for eventName, listeners of @namespaces[namespace] ? {}

      for listener in listeners

        continue if -1 is index = @events[eventName].indexOf listener
        @events[eventName].splice index, 1

    delete @namespaces[namespace]

    return

  on: (eventNames, f, that, once) ->

    eventNames = [eventNames] unless Array.isArray eventNames

    for eventName in eventNames

      @onSingleEvent eventName, f, that, once

    return

  onSingleEvent: (eventName, f, that, once) ->

    {eventName, namespace} = parseEventName eventName
    listener = new EventEmitterListener(
      f, that, eventName, namespace, once
    )

    (@events[eventName] ?= []).push listener
    ((@namespaces[namespace] ?= {})[eventName] ?= []).push listener

module.exports = class EventEmitter

  # Add listeners to an object. *eventName* is a (possibly) namespaced event
  # to listen for. *f* is a function to be called when the event fires, and
  # *that*, if specified, is the 'this' variable in the callback. 'this'
  # defaults to the object upon which the event listener is registered.
  on: (eventNames, f, that = null) -> internal(@).on eventNames, f, that, false

  once: (eventNames, f, that = null) -> internal(@).on eventNames, f, that, true

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
  off: (eventNames, f) -> internal(@).off eventNames, f

  # Notify ALL the listeners!
  emit: (eventName) ->

    candidates = internal(@).candidatesFor eventName
    return unless candidates.length > 0

    # analytics.tally "eventEmitter:#{name}"

    for candidate in candidates

      @off "#{
        candidate.eventName
      }.#{
        candidate.namespace
      }", candidate.f if candidate.once

      offset = if eventName isnt '*' then 1 else 0

      # Fast path...
      if arguments.length is offset
        candidate.bound()
      else if arguments.length is offset + 1
        candidate.bound arguments[offset]
      else if arguments.length is offset + 2
        candidate.bound arguments[offset], arguments[offset + 1]
      else if arguments.length is offset + 3
        candidate.bound arguments[offset], arguments[offset + 1], arguments[offset + 2]
      else if arguments.length is offset + 4
        candidate.bound arguments[offset], arguments[offset + 1], arguments[offset + 2], arguments[offset + 3]
      else if arguments.length is offset + 5
        candidate.bound arguments[offset], arguments[offset + 1], arguments[offset + 2], arguments[offset + 3], arguments[offset + 4]
      else
        if offset is 0
          candidate.bound.apply candidate.that, arguments
        else
          candidate.bound.apply candidate.that, (arg for arg, i in arguments when i > offset)

    return
