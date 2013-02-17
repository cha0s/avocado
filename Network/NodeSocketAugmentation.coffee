
_ = require 'Utility/underscore'

module.exports = (socket) ->
	
	socket.on 'error', -> socket.emit 'disconnect'
	socket.on 'close', -> socket.emit 'disconnect'
	
	emit = socket.emit
	socket.emit = (event, args...) ->
		
		emit.apply socket, ['disconnect'] if event is 'close'
		
		return emit.apply(
			socket
			[event].concat args
		) if _.contains [
			'newListener'
			'connect', 'data', 'end', 'timeout', 'drain'
			'error', 'close' 
		], event
		
		packet =
			type: event
			data: args[0]
		
		socket.write JSON.stringify packet
		socket.write '\n'
	
	packetData = ''
	socket.on 'data', (data) ->
	
		packetData += data
		
		packets = packetData.split '\n'
		
		return if packets.length is 0
		
		packetData = packets.splice -1, 1
		
		for {type, data} in (_.map packets, (packet) -> JSON.parse packet)
			
			emit.apply socket, [type, data]
		
	undefined	
