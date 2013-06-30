
_ = require 'Utility/underscore'

Q = require 'Utility/Q'

Q.asap = (promiseOrValue, fulfilled, rejected, progressed) ->
	
	if Q.isPromise promiseOrValue
		
		Q.when promiseOrValue, fulfilled, rejected, progressed
		
	else
		
		fulfilled ?= _.identity
		Q.resolve fulfilled promiseOrValue

Q.allAsap = (promisesOrValues, fulfilled, rejected) ->
	
	deferred = Q.defer()
	
	if _.some promisesOrValues, Q.isPromise
		
		promises = for promiseOrValue in promisesOrValues
			Q.asap promiseOrValue
		
		fulfilled ?= _.identity
		rejected ?= _.identity
		
		Q.all(
			promises
		).then(
			(results) -> deferred.resolve fulfilled results
			(error) -> deferred.reject rejected error
		)
		
	else
		
		deferred.resolve fulfilled (value for value in promisesOrValues)
	
	deferred.promise
