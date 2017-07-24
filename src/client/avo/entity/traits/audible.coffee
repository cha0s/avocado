
_ = require 'vendor/underscore'
Promise = require 'vendor/bluebird'

ArrayExt = require 'avo/extension/array'
Vector = require 'avo/extension/vector'

Sound = require 'avo/sound'

Trait = require './trait'

module.exports = class Audible extends Trait

  constructor: ->
    super

    @_sounds = {}

  stateDefaults: ->

    sounds: {}
    soundBanks: {}

  initialize: ->

    soundPromises = for soundIndex, O of @state.sounds

      # Look for sounds in the entity directory if no URI was explicitly given.
      O.uri = "#{@entity.uri()}/sounds/#{soundIndex}.png" unless O.uri?

      do (soundIndex) => Sound.load(O.uri).then (sound) =>
        @_sounds[soundIndex] = sound

    Promise.all soundPromises

  actions: ->

    playOutsideSound: (uri) -> Sound.load(uri).then (sound) -> sound.play()

    playRandomSoundInBank: (bank) ->
      return unless (bank = @state.soundBanks[bank])?

      randomSound = ArrayExt.randomElement bank

      @_sounds[randomSound].play()
