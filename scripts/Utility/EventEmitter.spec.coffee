
EventEmitter = require 'Utility/EventEmitter'
Mixin = require 'Utility/Mixin'

describe 'EventEmitter', ->
	
	O = null
	
	spy =
		namedEvents: ->
		namespacedEvents: ->
		removeListenerNameFunction: ->
		removeListenerNameAndNamespace: ->
		removeListenerNamespace: ->
		removeListenerName: ->
		
	beforeEach ->
		
		O = {}
		Mixin O, EventEmitter
	
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
		