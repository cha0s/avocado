
module.exports = config = {}

config.fs =

  srcRoot: '.'
  resourcePath: 'resource'
  uiPath: 'ui'

config.graphics =

  resolution: [1280, 720]
  renderer: 'auto'

config.input =

  mouseMovePerSecond: 50

config.timing =

  ticksPerSecond: 10
  rendersPerSecond: 60

config.promises =

  longStackTraces: false

if process? and process.versions['node-webkit']

  config.platform = 'node-webkit'

else

  config.platform = 'browser'

