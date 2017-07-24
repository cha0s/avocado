
Promise = require 'vendor/bluebird'

Actions = require 'avo/behavior/actions'
Conditions = require 'avo/behavior/conditions'

Trait = require 'avo/entity/traits/trait'

module.exports = class Alive extends Trait

  stateDefaults: ->

    health: 100
    deathConditions: [
      operator: '<='
      operands: [
        value: selector: 'entity:health'
      ,
        literal: 0
      ]
    ]
    deathActions: [
      selector: 'entity:setHealth'
      args: [
        []
        [
          literal: 0
        ]
      ]
    ,
      selector: 'entity:playOutsideSound'
      args: [
        []
        [
          literal: '/sound/death'
        ]
      ]
    ,
      selector: 'entity:transition'
      args: [
        []
        [
          literal:
            scaleX: 0, scaleY: 2
            tintRed: 255, tintGreen: 0, tintBlue: 0
        ,
          literal: 150
        ]
      ]
    ]

  constructor: ->
    super

    @_deathActions = new Actions()
    @_deathConditions = new Conditions()
    @_dying = false

  initialize: ->

    Promise.allAsap [
      @_deathActions.fromObject @state.deathActions.concat [
        selector: 'entity:signal'
        args: [
          []
          [
            literal: 'finishedDying'
          ]
        ]
      ]
      @_deathConditions.fromObject @state.deathConditions
    ]

  properties: ->

    health: {}

  actions: ->

    die: ->

      @entity.emit 'dying'
      @entity.on 'finishedDying', @entity.destroy, @entity

  signals: ->

    dying: -> @_dying = true

    tookDamage: (damage) ->

      @entity.setHealth @entity.health() - damage

  handler: ->

    ticker: (elapsed) ->

      if not @_dying and @_deathConditions.check @entity.context()

        @entity.die()

      if @_dying

        @_deathActions.tick @entity.context(), elapsed
