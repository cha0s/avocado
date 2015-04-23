
_ = require 'avo/vendor/underscore'
Promise = require 'avo/vendor/bluebird'

config = require 'avo/config'

# Much more debugging information for promises.
Promise.longStackTraces() if config.get 'promises:longStackTraces'

Promise.asap = (promiseOrValue, fulfilled, rejected) ->

	if Promise.is promiseOrValue

		promiseOrValue.then(fulfilled).catch rejected

	else

		try

			fulfilled? promiseOrValue

		catch error

			rejected? error

Promise.allAsap = (promisesOrValues, fulfilled, rejected) ->

	promises = _.filter(
		promisesOrValues
		(promiseOrValue) -> Promise.is promiseOrValue
	)

	if promises.length

		Promise.all(promises).then((values) ->

			fulfilled? values

		).catch rejected

	else

		try

			fulfilled? (value for value in promisesOrValues)

		catch error

			rejected? error

Promise.when = (promiseOrValue, resolved, rejected) ->

	Promise.cast(promiseOrValue).then resolved, rejected
