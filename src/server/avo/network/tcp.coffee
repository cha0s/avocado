
Promise = require 'vendor/bluebird'

Socket = require 'server/avo/network/socket'
Network = require 'server/avo/network'

module.exports = class TcpNetwork extends Network

  listen: (options) ->
    self = this

    socketId = 0

    new Promise (resolve, reject) ->

      server = require('net').createServer()

      server.listen port: options.port

      server.on 'connection', (netSocket) ->

        socket = new class NetSocket extends Socket

          send: (message) -> netSocket.write JSON.stringify message

        socket.id = ++socketId

        netSocket.on 'data', (chunk) ->
          socket.emit 'avo-raw-message', JSON.parse chunk

        self.emit 'avo-raw-connection', socket

      server.on 'listening', ->
        self.emit 'listening'
        resolve()
