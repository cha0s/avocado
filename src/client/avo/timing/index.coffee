
# Adapted from https://gist.github.com/paulirish/1579671#gistcomment-91515
raf = window.requestAnimationFrame
caf = window.cancelAnimationFrame

w = window
for vendor in ['ms', 'moz', 'webkit', 'o']
  break if raf
  raf = w["#{vendor}RequestAnimationFrame"]
  caf = (
    w["#{vendor}CancelAnimationFrame"] or
    w["#{vendor}CancelRequestAnimationFrame"]
  )

# rAF is built in but cAF is not.
if raf and not caf
  browserRaf = raf
  canceled = {}

  raf = (fn) -> id = browserRaf (time) ->
    return fn time unless id of canceled
    delete canceled[id]

  caf = (id) -> canceled[id] = true

# Handle legacy browsers which don’t implement rAF
unless raf
  targetTime = 0

  raf = (fn) ->
    targetTime = Math.max targetTime + 16, currentTime = +new Date
    w.setTimeout (-> fn +new Date), targetTime - currentTime

  caf = (id) -> clearTimeout id

exports.requestAnimationFrame = raf
exports.cancelAnimationFrame = caf

# setInterval, but for animations. :)
said = 1
handles = {}
exports.setAnimation = (fn) ->
  id = said++

  handles[id] = raf ifn = do (id) -> (time) ->
    return unless handles[id]?
    fn time
    handles[id] = raf ifn

  return id

exports.clearAnimation = (id) -> handles[id] = null
