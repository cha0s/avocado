
EventEmitter = require './EventEmitter'
Mixin = require './Mixin'

describe 'EventEmitter', ->

  O = null

  spy =
  	namedEvents: ->
  	namespacedEvents: ->
  	onceEvent: ->
  	onceEventNamespace: ->
  	removeListenerNameFunction: ->
  	removeListenerNameAndNamespace: ->
  	removeListenerNamespace: ->
  	removeListenerName: ->

  beforeEach ->

  	O = {}
  	Mixin O, EventEmitter
  	EventEmitter.call O

  it "can listen to signals on event name", ->

  	spyOn spy, 'namedEvents'
  	O.on 'namedEvents', spy.namedEvents

  	O.emit 'namedEvents'

  	expect(spy.namedEvents.calls.length).toEqual 1

  it "can listen to signals on event name, with a namespace", ->

  	spyOn spy, 'namespacedEvents'
  	O.on 'namespacedEvents.ns', spy.namespacedEvents

  	O.emit 'namespacedEvents'

  	expect(spy.namespacedEvents.calls.length).toEqual 1

  it "can listen to signals only once", ->

  	spyOn spy, 'onceEvent'
  	O.once 'onceEvent', spy.onceEvent

  	O.emit 'onceEvent'
  	O.emit 'onceEvent'
  	O.emit 'onceEvent'

  	expect(spy.onceEvent.calls.length).toEqual 1

  it "can remove signal listeners by name and function", ->

  	spyOn spy, 'removeListenerNameFunction'

  	O.on 'removeListenerNameFunction', spy.removeListenerNameFunction
  	O.emit 'removeListenerNameFunction'
  	expect(spy.removeListenerNameFunction.calls.length).toEqual 1

  	O.off 'removeListenerNameFunction', spy.removeListenerNameFunction
  	O.emit 'removeListenerNameFunction'
  	expect(spy.removeListenerNameFunction.calls.length).toEqual 1

  it "can remove signal listeners by name and namespace", ->

  	spyOn spy, 'removeListenerNameAndNamespace'

  	O.on 'removeListenerNameAndNamespace.ns', spy.removeListenerNameAndNamespace
  	O.emit 'removeListenerNameAndNamespace'
  	expect(spy.removeListenerNameAndNamespace.calls.length).toEqual 1

  	O.off 'removeListenerNameAndNamespace.ns'
  	O.emit 'removeListenerNameAndNamespace'
  	expect(spy.removeListenerNameAndNamespace.calls.length).toEqual 1

  it "can remove signal listeners by namespace", ->

  	spyOn spy, 'removeListenerNamespace'

  	O.on 'removeListenerNamespace.ns', spy.removeListenerNamespace
  	O.emit 'removeListenerNamespace'
  	expect(spy.removeListenerNamespace.calls.length).toEqual 1

  	O.off '.ns'
  	O.emit 'removeListenerNamespace'
  	expect(spy.removeListenerNamespace.calls.length).toEqual 1

  it "can remove signal listeners by name", ->

  	spyOn spy, 'removeListenerName'

  	O.on 'removeListenerName', spy.removeListenerName
  	O.emit 'removeListenerName'
  	expect(spy.removeListenerName.calls.length).toEqual 1

  	O.off 'removeListenerName'
  	O.emit 'removeListenerName'
  	expect(spy.removeListenerName.calls.length).toEqual 1

  it "can pass data to callbacks", ->

  	data = null
  	callback = -> data = arguments[0]

  	O.on 'passData', callback
  	O.emit 'passData', 420

  	expect(data).toEqual 420

  describe 'regressions', ->

  	it "can listen to namespaced signals only once", ->

  		expect(->

  			spyOn spy, 'onceEventNamespace'
  			O.once 'onceEvent.Namespace', spy.onceEventNamespace

  			O.emit 'onceEvent'
  			O.emit 'onceEvent'
  			O.emit 'onceEvent'

  			expect(spy.onceEventNamespace.calls.length).toEqual 1

  		).not.toThrow()
