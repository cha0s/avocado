
module.exports = class ConnectionManager

  constructor: -> @_connections = {}

  connections: -> @_connections

  addConnection: (socket) ->

    @emit 'connection', @_connections[socket.id] = socket: socket

  connection: (id) -> @_connections[id]

  removeConnection: (id) ->

    @emit 'disconnection', @_connections[id]
    delete @_connections[id]

  send: (message) ->

    connection.socket.send message for id, connection of @_connections
