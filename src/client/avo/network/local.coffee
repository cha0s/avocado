
Promise = require 'vendor/bluebird'

Network = require 'avo/network'

fakeServer = require 'server/avo/network/fake-server'

module.exports = class LocalNetwork extends Network

  connect: (options) ->
    self = this

    new Promise (resolve, reject) ->

      fakeServer.on 'serverMessage', (message) ->
        self.emit 'avo-raw-message', message

      # Spin up server
      require('server').start type: 'local'

      setTimeout ->
        self.emit 'connect'
      , 0

      resolve()

  send: (message) -> fakeServer.clientWrite message
