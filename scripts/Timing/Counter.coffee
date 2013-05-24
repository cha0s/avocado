# SPI proxy and constant definitions.

# **Counter** keeps track of time.

Counter = require('Timing').Counter

# Get the current timestamp. This will be different based on platform, but
# calling one second later will always return timestamp + 1.
Counter::current = Counter::['%current']
