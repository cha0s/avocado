
# **Counter** keeps track of time.

exports.proxy = ({Counter}) ->

	# Get the current timestamp. This will be different based on platform, but
	# calling one second later will always return timestamp + 1.
	Counter::current = Counter::['%current']
