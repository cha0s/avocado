
Promise = require 'vendor/bluebird'

Behavior = require 'avo/behavior'
Actions = require './actions'

describe 'Behavior', ->

  describe 'actions', ->

    it "can execute promised actions", (done) ->

      actions = Behavior.instantiate actions: [
        selector: 'first'
      ,
        selector: 'second'
      ,
        selector: 'third'
      ]

      v = 0
      context =
        first: -> v = 100
        second: (state) -> state.setPromise Promise.resolve().then -> v += 100
        third: -> v += 100

      actions.on 'actionsFinished', ->
        expect(v).toBe 300
        done()

      actions.tick context, 10
      expect(v).toBe 100

      # Wait for the promise, la dee da
      setTimeout ->
        expect(v).toBe 200
        actions.tick context, 10
      , 5

    it "executes non-promised actions immediately", (done) ->

      actions = Behavior.instantiate actions: [
        selector: 'first'
      ,
        selector: 'second'
      ]

      v = 0
      context =
        first: -> v = 100
        second: (state) -> v += 100

      actions.on 'actionsFinished', ->
        expect(v).toBe 200
        done()

      actions.tick context, 10
