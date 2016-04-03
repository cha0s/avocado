
_ = require 'avo/vendor/underscore'

exports.fastApply = (f, args, that = null) ->

  return f.apply that, args if args.length > 5

  if args.length is 0
    f.call that
  else if args.length is 1
    f.call that, args[0]
  else if args.length is 2
    f.call that, args[0], args[1]
  else if args.length is 3
    f.call that, args[0], args[1], args[2]
  else if args.length is 4
    f.call that, args[0], args[1], args[2], args[3]
  else if args.length is 5
    f.call that, args[0], args[1], args[2], args[3], args[4]
