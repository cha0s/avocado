
_ = require 'avo/vendor/underscore'
Promise = require 'avo/vendor/bluebird'

#Promise.longStackTraces()

Promise.asap = (promiseOrValue, fulfilled, rejected, progressed) ->
	
	if Promise.is promiseOrValue
		
		promiseOrValue.then fulfilled, rejected, progressed
	
	else
		
		(fulfilled ? ->) promiseOrValue

Promise.allAsap = (promisesOrValues, fulfilled, rejected, progressed) ->

	if _.some promisesOrValues, Promise.is
		
		promises = _.filter(
			promisesOrValues
			(promiseOrValue) -> Promise.is promiseOrValue
		)
		
		fulfilled ?= ->
		rejected ?= ->
		
		Promise.all(
			promises
		).then(
			->
				fulfilled _.map promisesOrValues, (promiseOrValue) ->
					if Promise.is promiseOrValue
						promiseOrValue.inspect().value()
					else
						promiseOrValue

			(error) -> rejected error
		)
		
	else
		
		(fulfilled ? _.identity) (value for value in promisesOrValues)

Promise.when = (promiseOrValue, resolved, rejected, progressed) ->

	Promise.cast(promiseOrValue).then resolved, rejected, progressed
