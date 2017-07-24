
Promise = require 'vendor/bluebird'

Socket = require 'server/avo/network/socket'
Network = require 'server/avo/network'

fakeServer = require 'server/avo/network/fake-server'

module.exports = class LocalNetwork extends Network

  listen: (options) ->
    self = this

    socketId = 0

    new Promise (resolve, reject) ->

      socket = new class FakeSocket extends Socket

        send: (message) -> fakeServer.serverWrite message

      socket.id = ++socketId

      fakeServer.on 'clientMessage', (message) ->
        socket.emit 'avo-raw-message', message

      setTimeout ->
        self.emit 'listening'
      , 0

      setTimeout ->
        self.emit 'avo-raw-connection', socket
      , 0

      resolve()
