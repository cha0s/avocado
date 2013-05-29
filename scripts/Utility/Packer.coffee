
base64 = require 'Utility/base64'
Lzw = require 'Utility/Lzw'

exports.pack = (O) ->
	base64.toBase64 JSON.stringify Lzw.compress JSON.stringify O

exports.unpack = (packed) ->
	JSON.parse Lzw.decompress JSON.parse base64.fromBase64 packed
