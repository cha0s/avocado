
{Config} = require 'avo/config'

config = new Config()

for forward in [
  'get'
  'getOrCreate'
  'has'
  'set'
]
  do (forward) -> exports[forward] = -> config[forward].apply config, arguments

exports.tally = (key, value = 1) ->
  v = config.getOrCreate key, tally: 0
  if v.tally? then v.tally += value else v.tally = value
