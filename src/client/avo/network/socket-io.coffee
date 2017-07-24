
io = require 'vendor/socket.io'

Promise = require 'vendor/bluebird'

Network = require 'avo/network'

module.exports = class SocketIoNetwork extends Network

  constructor: ->
    super

    @socket = null

  connect: (options) ->
    self = this

    connectionStringFromOptions = (options) ->

      options.host ?= window.location.host
      options.protocol ?= window.location.protocol
      options.path ?= '/'
      options.port ?= window.location.port

      return "#{
        options.protocol
      }//#{
        options.host
      }:#{
        options.port
      }#{
        options.path
      }"

    new Promise (resolve, reject) ->

      self.socket = io.connect connectionStringFromOptions options

      self.socket.on 'error', (error) -> self.emit 'error', error

      self.socket.on 'connect', ->
        resolve()
        self.emit 'connect'

      self.socket.on 'disconnect', -> self.emit 'disconnect'

      self.socket.on 'socket.io-avo-raw-message', (chunk) ->

        self.emit 'avo-raw-message', JSON.parse chunk

      self.socket.send = (message) ->
        self.socket.emit 'socket.io-avo-raw-message', message

  send: (message) -> @socket.send JSON.stringify message
