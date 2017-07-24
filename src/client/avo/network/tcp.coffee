
net = require 'net'

Promise = require 'vendor/bluebird'

Network = require 'avo/network'

module.exports = class TcpNetwork extends Network

  constructor: ->
    super

    @socket = null

  connect: (options) ->
    self = this

    new Promise (resolve, reject) ->

      self.socket = net.connect options

      self.socket.on 'error', (error) -> self.emit 'error', error

      self.socket.on 'connect', ->
        resolve()
        self.emit 'connect'

      self.socket.on 'data', (chunk) ->

        self.emit 'avo-raw-message', JSON.parse chunk

      self.socket.send = self.socket.write

  send: (message) -> @socket.send JSON.stringify message
