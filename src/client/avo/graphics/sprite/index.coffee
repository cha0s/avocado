
module.exports = if window? then require './browser' else require './headless'
