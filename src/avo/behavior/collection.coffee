
i8n = require 'avo/vendor/inflection'
Promise = require 'avo/vendor/bluebird'

BehaviorItem = require './behaviorItem'

module.exports = (key) ->

  singleKey = i8n.singularize key

  class Collection extends BehaviorItem

    constructor: ->

      this["_#{key}"] = []

    @::[singleKey] = (index) -> this["_#{key}"][index]

    count: -> this["_#{key}"].length

    fromObject: (Os) ->

      Promise.allAsap(

        for O in Os

          Thing = require "avo/behavior/#{singleKey}"
          thing = new Thing()
          thing.fromObject O

        (things) =>

          this["_#{key}"] = things
          this
      )

    toJSON: ->

      O = {}
      O[key] = this["_#{key}"].map (_) -> _.toJSON()
      O
