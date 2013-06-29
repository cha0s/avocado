
Q = require 'Utility/Q'

Q.asap = (promiseOrValue, fulfilled, rejected, progressed) ->
	
    if Q.isPromise promiseOrValue
    	
    	Q.when promiseOrValue, fulfilled, rejected, progressed
    	
    else
    	
    	Q.resolve fulfilled promiseOrValue
