
Promise = require 'vendor/bluebird'

Socket = require 'server/avo/network/socket'
Network = require 'server/avo/network'

module.exports = class SocketIoNetwork extends Network

  listen: (options) ->
    self = this

    new Promise (resolve, reject) ->

      server = require('http').createServer()
      io = require('socket.io')(server)

      server.listen port: options.port

      io.on 'connection', (socketIoSocket) ->

        socket = new class SocketIoSocket extends Socket

          send: (message) -> socketIoSocket.emit(
            'socket.io-avo-raw-message'
            JSON.stringify message
          )

        socket.id = socketIoSocket.id

        socketIoSocket.on 'socket.io-avo-raw-message', (chunk) ->
          socket.emit 'avo-raw-message', JSON.parse chunk

        socketIoSocket.on 'disconnect', ->
          socket.emit 'disconnect'
          self.emit 'disconnection', socket

        self.emit 'avo-raw-connection', socket

      server.on 'listening', ->
        self.emit 'listening'
        resolve()
