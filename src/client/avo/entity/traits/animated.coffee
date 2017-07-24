
Promise = require 'vendor/bluebird'

Vector = require 'avo/extension/vector'

Animation = require 'avo/graphics/animation'

Trait = require './trait'

module.exports = class Animated extends Trait

  @dependencies: [
    'corporeal'
    'visible'
  ]

  constructor: ->
    super

    @_animations = {}

  stateDefaults: ->

    animations: {}
    animationIndex: 'initial'
    preserveFrameWhenMoving: false

  initialize: ->

    animationPromises = for animationIndex, O of @state.animations

      # Look for animations in the entity directory if no URI was
      # explicitly given.
      O.uri = @entity.uri().replace(
        '.entity.json',
        '/' + animationIndex + '.animation.json'
      ) unless O.uri?

      do (animationIndex, O) =>
        Animation.load(O.uri).then (animation) =>

          @_animations[animationIndex] = animation

          animation.sprite().setOrigin(
            O.origin ? Vector.scale animation.frameSize(), .5
          )

          animation.start()

    Promise.all animationPromises

  _snapPosition: ->

    for i, animation of @_animations
      animation.sprite().setPosition Vector.sub(
        @entity.position()
        Vector.add(
          @entity.offset()
          @state.animations[i].offset ? [0, 0]
        )
      )

    return

  _snapRotation: ->

    for i, animation of @_animations
      animation.sprite().setRotation @entity.rotation()

    return

  properties: ->

    animationIndex: {}

  signals: ->

    traitsChanged: ->

      @_snapPosition()
      @_snapRotation()

    addToLocalContainer: (localContainer) ->

      for i, animation of @_animations
        animation.sprite().setIsVisible false
        localContainer.addChild animation.sprite()

      @_animations[@state.animationIndex].sprite().setIsVisible true

    animationIndexChanged: (oldIndex) ->

      @_animations[oldIndex].sprite().setIsVisible false
      @_animations[@state.animationIndex].sprite().setIsVisible true

    directionChanged: ->

      for i, animation of @_animations
        animation.setDirection @entity.direction()

    isMovingChanged: ->

      if @entity.isMoving()

        index = if @state.preserveFrameWhenMoving
          @entity.animation()?.index()
        else
          0

        @entity.setAnimationIndex @entity.mobilityAnimationIndex()
        @entity.animation()?.setIndex index

      else

        @entity.setAnimationIndex 'initial'

    offsetChanged: -> @_snapPosition()

    positionChanged: -> @_snapPosition()

    rotationChanged: -> @_snapRotation()

  values: ->

    animation: -> @_animations[@state.animationIndex]

  handler: ->

    ticker: (elapsed) ->

      @entity.animation()?.tick elapsed

  toJSON: ->

    O = super
    return O unless O.state?

    state = O.state
    delete O.state

    # Delete animation URIs that are just using the entity's uri, since
    # that's the default.
    if state.animations?
      uri = @entity.uri().replace '.entity.json', ''

      for index, animation of state.animations
        if animation.uri is "#{uri}/#{index}.animation.json"
          delete animation.uri

      delete state.animations if _.isEmpty state.animations

    O.state = state unless _.isEmpty state
    O
