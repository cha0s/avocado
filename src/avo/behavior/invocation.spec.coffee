
Promise = require 'avo/vendor/bluebird'

Behavior = require 'avo/behavior'
Invocation = require './invocation'

describe 'Behavior', ->

  describe 'invocation', ->

    it "can do a scalar invocation", ->

      invocation = Behavior.instantiate invocation: selector: 'test'

      expect(invocation.invoke test: 69).toBe 69

    it "can do a function invocation", ->

      invocation = Behavior.instantiate(
        invocation: selector: 'test', args: [
          [
            literal: 420
          ]
        ]
      )

      expect(invocation.invoke test: (arg) -> arg).toBe 420

    it "correctly passes a functional state object", (done) ->

      invocation = Behavior.instantiate(
        invocation: selector: 'foo:test'
      )

      deferred = Promise.defer()
      deferred.promise.then done

      foo = ->
        expect(arguments.length).toBe 0

        test: (state) ->
          state.setPromise deferred.promise
          state.setTicker (elapsed) -> deferred.resolve() if elapsed is 10

      state = new Invocation.State()
      invocation.invoke foo: foo, state

      setTimeout ->
        state.tick 10
      , 0
