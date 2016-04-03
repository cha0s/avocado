
###

# Total elapsed time.
elapsed = 0
exports.elapsed = -> elapsed
exports.setElapsed = (e) -> elapsed = e

# Time elapsed per engine tick.
tickElapsed = 0
exports.tickElapsed = -> tickElapsed
exports.setTickElapsed = (e) -> tickElapsed = e

###
