
buzz = require 'avo/vendor/buzz'
Promise = require 'avo/vendor/bluebird'

config = require 'avo/config'

module.exports = class Sound

	@load: (uri) ->

		new Promise (resolve, reject) ->

			_sound = new buzz.sound "#{config.get 'fs:resourcePath'}#{uri}", formats: [
				'ogg', 'mp3', 'aac', 'wav'
			]

			_sound.bind 'error', -> reject sound.error

			_sound.bind 'canplaythrough', ->

				sound = new Sound()

				sound._sound = _sound

				resolve sound

	play: ->

		@_sound.play()

		this

	pause: ->

		@_sound.pause()

		this

	stop: ->

		@_sound.stop()

		this

	loop: ->

		@_sound.loop()

		this

	unloop: ->

		@_sound.unloop()

		this

	mute: ->

		@_sound.mute()

		this

	unmute: ->

		@_sound.unmute()

		this

	setVolume: (volume) ->

		@_sound.setVolume volume

		this

	fadeIn: (duration, fn) ->

		@_sound.fadeIn duration, fn

		this

	fadeOut: (duration, fn) ->

		@_sound.fadeOut duration, fn

		this
