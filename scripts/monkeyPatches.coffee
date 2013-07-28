
_ = require 'Utility/underscore'

kew = require 'Utility/kew'
When = require 'Utility/when'
Q = require 'Utility/Q-kris'

kew.when = (value) ->
	defer = kew.defer()
	setTimeout(
		-> defer.resolve value
		0
	)
	defer.promise

defer = When.defer
When.defer = ->
	deferred = defer()
	
	deferred.makeNodeResolver ?= ->
		(error, args...) ->
			return deferred.reject error if error?
			deferred.resolve.apply deferred, args
			
	deferred

for lib in [kew, When, Q]

	do (lib) ->
		
		lib.asap = (promiseOrValue, fulfilled, rejected, progressed) ->
			
			if lib.isPromise promiseOrValue
				
				promiseOrValue.then fulfilled, rejected, progressed
				
			else
				
				(fulfilled ? _.identity) promiseOrValue
		
		lib.allAsap = (promisesOrValues, fulfilled, rejected) ->
			
			if _.some promisesOrValues, lib.isPromise
				
				promises = _.filter(
					promisesOrValues
					(promiseOrValue) -> lib.isPromise promiseOrValue
				)
				
				fulfilled ?= _.identity
				rejected ?= _.identity
				
				lib.all(
					promises
				).then(
					->
						fulfilled _.map(
							promisesOrValues
							(promiseOrValue) ->
								if lib.isPromise promiseOrValue
									promiseOrValue.valueOf()
								else
									promiseOrValue
						)
					(error) -> rejected error
				)
				
			else
				
				(fulfilled ? _.identity) (value for value in promisesOrValues)
