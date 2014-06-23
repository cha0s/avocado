
_ = require 'avo/vendor/underscore'

exports.fastApply = (f, args, that = null) ->
	
	return f.apply that, args if args.length > 7
		
	f = if that? then _.bind f, that else f
	
	if args.length is 0
		f()
	else if args.length is 1
		f args[0]
	else if args.length is 2
		f args[0], args[1]
	else if args.length is 3
		f args[0], args[1], args[2]
	else if args.length is 4
		f args[0], args[1], args[2], args[3]
	else if args.length is 5
		f args[0], args[1], args[2], args[3], args[4]
	else if args.length is 6
		f args[0], args[1], args[2], args[3], args[4], args[5]
	else if args.length is 7
		f args[0], args[1], args[2], args[3], args[4], args[5], args[6]
