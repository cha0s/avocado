
base64 = require 'vendor/base64'
lzString = require 'vendor/lz-string'

exports.pack = (O) -> lzString.compressToBase64 JSON.stringify O

exports.unpack = (packed) -> JSON.parse lzString.decompressFromBase64 packed
