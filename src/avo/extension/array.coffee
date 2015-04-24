
exports.randomElement = (array) ->
	array[Math.floor Math.random() * array.length]

exports.fastPushArray = (l, r) ->
	l.push e for e in r
	return
