
Promise = require 'vendor/bluebird'

BehaviorItem = require './behaviorItem'
Routine = require './routine'

module.exports = class Routines extends BehaviorItem

  constructor: ->

    @_routines = {}

  fromObject: (O) ->

    Promise.allAsap(

      for index, routine of O
        (@_routines[index] = new Routine()).fromObject routine

      => this
    )

  routine: (index) -> @_routines[index]

  toJSON: ->

    O = routines: {}
    for index, routine of @_routines
      O.routines[index] = routine.toJSON()
    O
