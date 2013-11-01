# **EventEmitter** is a mixin which lends the ability to emit events and
# manage the registration of listeners who listen for the emission of the
# events.

_ = require 'Utility/underscore'
Debug = require 'Debug'
Mixin = require 'Mixin/Mixin'

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
	on: (eventNamesOrEventName, f, that = this) ->
		
		eventNames = if _.isArray eventNamesOrEventName
			eventNamesOrEventName
		else
			[eventNamesOrEventName]
		
		
		for eventName in eventNames
			info = parseEventName eventName
			
			(@_events[info.event] ?= {})[f] =
				f: _.bind f, that 
				that: that
				namespace: info.namespace
				
			(@_namespaces[info.namespace] ?= {})[f] =
				event: info.event
			
		return
		
	once: (eventName, f, that = this) ->
		@on eventName, f, that
		
		info = parseEventName eventName
		@_events[info.event][f]['once'] = true
		
		return
		
	# Remove listeners from an object.
	# 
	# There are four ways to use avo.**EventEmitter**.off:
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
			
			delete @_events[info.event][f]
			delete @_namespaces[info.namespace][f]
			
			return
		
		# No namespace? Remove every matching event.
		if '' is info.namespace
			for f of @_events[info.event]
				delete @_namespaces[@_events[info.event][f].namespace][f]
				delete @_events[info.event][f]
			return
	
		# Namespaced event? Remove it.
		if info.event
			for f of @_events[info.event]
				if info.namespace != @_events[info.event][f].namespace
					continue
				delete @_namespaces[info.namespace][f]
				delete @_events[info.event][f]
			return
		
		# Only a namespace? Remove all events associated with it.
		for f of @_namespaces[info.namespace]
			delete @_events[@_namespaces[info.namespace][f].event][f]
			delete @_namespaces[info.namespace][f]
		
		undefined
		
	# Notify ALL the listeners!
	emit: (name) ->
		return if not @_events[name]?
		
#		v = Debug.variables()
#		v['emit'] ?= {}
#		v['emit'][name] ?= {}
#		className = /(\w+)\(/.exec(@constructor.toString())[1]
#		v['emit'][name][className] ?= 0
#		v['emit'][name][className] += 1
		
		args = if arguments.length > 1
			arg for arg, i in arguments when i > 0
		else
			[]
		
		for callback of @_events[name]
			spec = @_events[name][callback]
			
			f = spec.f
			@off "#{name}.#{spec.namespace}", f if spec.once
			
			switch args.length
				when 0
					f()
				when 1
					f args[0]
				when 2
					f args[0], args[1]
				when 3
					f args[0], args[1], args[2]
				when 4
					f args[0], args[1], args[2], args[3]
				else
					f.apply spec.that, args

		undefined

EventEmitter.Mixin = (O) -> Mixin O, EventEmitter
