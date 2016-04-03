
{Config} = require 'avo/config'

config = new Config()

reportKeys = []

exports.markAsReport = (key) -> reportKeys.push key

for forward in [
  'get'
  'getOrCreate'
  'has'
  'set'
]
  do (forward) -> exports[forward] = -> config[forward].apply config, arguments

exports.reportData = ->
  report = {}
  report[key] = config.get key for key in reportKeys
  return report

exports.tally = (key, value = 1) ->
  v = config.getOrCreate key, tally: 0
  if v.tally? then v.tally += value else v.tally = value
