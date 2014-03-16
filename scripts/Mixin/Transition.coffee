# **Transition** is a **Mixin** which lends the ability to handle timed
# transitions of arbitrary property methods residing on the mixed-in object.
#
# You can use this mixin like this:
#
#     Mixin yourObject, Transition
#     
#     yourObject.transition(
#       x: 100
#       2000
#       'easeOutQuad'
#     )
#
# The value of yourObject.x() will transition towards 100 over the course of
# 2000 milliseconds. ***NOTE:*** yourObject **must** have the functions **x()**
# and **setX()** defined.
# 
# This function was heavily inspired by the existence of
# [jQuery.animate](http://api.jquery.com/animate/), though the API is ***NOT***
# compatible.

Timing = require 'Timing'

Mixin = require 'Mixin/Mixin'
Promise = require 'Utility/bluebird'
String = require 'Extension/String'

TransitionResult = class TransitionResult
	
	constructor: (@_object, @_props, speed, easing) ->
		
		# Speed might not get passed. If it doesn't, default to 100
		# milliseconds.
		@_speed = if 'number' is typeof speed
			speed
		else
			100
	
		# If easing isn't passed in as a function, attempt to look it up
		# as a string key into Transition.easing. If that fails, then
		# default to 'easeOutQuad'.
		@_easing = if 'function' isnt typeof easing
			Transition.easing[easing] ? Transition.easing['easeOutQuad']
		else
			easing
		
		@_original = {}
		@_change = {}
		@_method = {}
		
		for i, prop of @_props
			value = @_object[i]()
			
			@_original[i] = value
			@_change[i] = prop - value
			@_method[i] = String.setterName i
		
		# Set up the transition object.
		@_deferred = Promise.defer()
		@promise = @_deferred.promise
		
		@_elapsed = 0
		@_duration = @_speed / 1000

	# Immediately finish the transition. This will leave the object
	# in the fully transitioned state.
	skipTransition: ->
	
		# Just trick it into thinking the time passed and do one last
		# tick.
		@_elapsed = @_duration
		@tick()

	# Immediately stop the transition. This will leave the object in
	# its current state; potentially partially transitioned.				
	stopTransition: ->
	
		# Let any listeners know that the transition is complete.
		@_deferred.progress [@_elapsed, @_duration]
		@_deferred.resolve()

	# Tick callback. Called repeatedly while this transition is
	# running.
	tick: ->
		
		# Update the transition's elapsed time.
		@_elapsed += @elapsedSinceLast()
		
		# If we've overshot the duration, we'll fix it up here, so
		# things never transition too far (through the end point).
		if @_elapsed >= @_duration
			@_elapsed = @_duration
			
			for i of @_change
				if @_change[i]
					@_object[@_method[i]] @_props[i]
					
		else
		
			# Do easing for each property that actually changed.
			for i of @_change
				if @_change[i]
					@_object[@_method[i]] @_easing(
						@_elapsed,
						@_original[i],
						@_change[i],
						@_duration
					)
		
		# Stop if we're done.
		if @_elapsed is @_duration
			@stopTransition()
		else
			@_deferred.progress [@_elapsed, @_duration]

module.exports = Transition = class					

	TransitionResultOutOfBand = class TransitionResultOutOfBand extends TransitionResult
	
		constructor: ->
			super
			
			@_last = Timing.TimingService.elapsed()
			@_interval = null
			
			@_startInterval()
			
		elapsedSinceLast: ->
			
			elapsed = Timing.TimingService.elapsed() - @_last
			@_last = Timing.TimingService.elapsed()
			elapsed
			
		startInterval: (result) ->
			
			@_interval = setInterval (-> @tick()), 10
		
		stopTransition: ->
			super
		
			# Stop the tick loop.
			clearInterval @_interval
		
	# Transition a set of properties at the specified speed in milliseconds,
	# using the specified easing function.
	transition: (
		props
		speed
		easing
	) ->
		
		new TransitionResultOutOfBand @, props, speed, easing

Transition.Mixin = (O) -> Mixin O, Transition

Transition.OutOfBand = Transition

Transition.InBand = class					

	TransitionResultInBand = class TransitionResultInBand extends TransitionResult
	
		elapsedSinceLast: -> Timing.TimingService.tickElapsed()
	
	# Transition a set of properties at the specified speed in milliseconds,
	# using the specified easing function.
	transition: (
		props
		speed
		easing
	) ->
		
		new TransitionResultInBand @, props, speed, easing

Transition.InBand.Mixin = (O) -> Mixin O, Transition.InBand

Transition.Vector = class

	constructor: (vector, Type = Transition) ->
		
		@[0] = vector[0]
		@[1] = vector[1]
		
		Mixin this, Type
		
	x: -> @[0]
	setX: (x) -> @[0] = x
	y: -> @[1]
	setY: (y) -> @[1] = y

Transition.Vector.OutOfBand = Transition.Vector

Transition.Vector.InBand = class extends Transition.Vector

	constructor: (vector) ->
		
		@[0] = vector[0]
		@[1] = vector[1]
		
		Mixin this, Transition.InBand
		
	x: -> @[0]
	setX: (x) -> @[0] = x
	y: -> @[1]
	setY: (y) -> @[1] = y
	
	vector: -> this

Transition.Value = class

	constructor: (value, key = 'value', Type = Transition) ->
		
		@["_#{key}"] = value
		
		@[key] = -> @["_#{key}"]
		@[String.setterName key] = (value) -> @["_#{key}"] = value
		
		Mixin this, Type

Transition.Value.OutOfBand = Transition.Value

Transition.Value.InBand = class extends Transition.Value

	constructor: (value, key = 'value') ->
		
		@["_#{key}"] = value
		
		@[key] = -> @["_#{key}"]
		@[String.setterName key] = (value) -> @["_#{key}"] = value
		
		Mixin this, Transition.InBand

# Registered easing functions. An easing function is a parametric equation
# that determines the value of a property over the time length of the
# transition.
Transition.easing = {}

###
 *
 * jQuery Easing v1.3 - http://gsgd.co.uk/sandbox/jquery/easing/
 * 
 * Uses the built in easing capabilities added In jQuery 1.1
 * to offer multiple easing options
 *
 * TERMS OF USE - jQuery Easing
 * 
 * Open source under the BSD License. 
 * 
 * Copyright Â© 2008 George McGinley Smith
 * All rights reserved.
 * 
 * Modified by Ruben Rodriguez <cha0s@therealcha0s.net>
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 * 
 * Redistributions of source code must retain the above copyright notice, this list of 
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list 
 * of conditions and the following disclaimer in the documentation and/or other materials 
 * provided with the distribution.
 * 
 * Neither the name of the author nor the names of contributors may be used to endorse 
 * or promote products derived from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 *  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED 
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 * OF THE POSSIBILITY OF SUCH DAMAGE. 
 *
 *
###
# Not worth the trouble of translating.
`
Transition.easing = {
	linear: function (t, b, c, d) {
		return b + c * t/d
	},
	easeInQuad: function (t, b, c, d) {
		return c*(t/=d)*t + b;
	},
	easeOutQuad: function (t, b, c, d) {
		return -c *(t/=d)*(t-2) + b;
	},
	easeInOutQuad: function (t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t + b;
		return -c/2 * ((--t)*(t-2) - 1) + b;
	},
	easeInCubic: function (t, b, c, d) {
		return c*(t/=d)*t*t + b;
	},
	easeOutCubic: function (t, b, c, d) {
		return c*((t=t/d-1)*t*t + 1) + b;
	},
	easeInOutCubic: function (t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;
	},
	easeInQuart: function (t, b, c, d) {
		return c*(t/=d)*t*t*t + b;
	},
	easeOutQuart: function (t, b, c, d) {
		return -c * ((t=t/d-1)*t*t*t - 1) + b;
	},
	easeInOutQuart: function (t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	},
	easeInQuint: function (t, b, c, d) {
		return c*(t/=d)*t*t*t*t + b;
	},
	easeOutQuint: function (t, b, c, d) {
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	},
	easeInOutQuint: function (t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	},
	easeInSine: function (t, b, c, d) {
		return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
	},
	easeOutSine: function (t, b, c, d) {
		return c * Math.sin(t/d * (Math.PI/2)) + b;
	},
	easeInOutSine: function (t, b, c, d) {
		return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
	},
	easeInExpo: function (t, b, c, d) {
		return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
	},
	easeOutExpo: function (t, b, c, d) {
		return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
	},
	easeInOutExpo: function (t, b, c, d) {
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
		return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
	},
	easeInCirc: function (t, b, c, d) {
		return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
	},
	easeOutCirc: function (t, b, c, d) {
		return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
	},
	easeInOutCirc: function (t, b, c, d) {
		if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
		return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
	},
	easeInElastic: function (t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	},
	easeOutElastic: function (t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b;
	},
	easeInOutElastic: function (t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
		return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
	},
	easeInBack: function (t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*(t/=d)*t*((s+1)*t - s) + b;
	},
	easeOutBack: function (t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	},
	easeInOutBack: function (t, b, c, d, s) {
		if (s == undefined) s = 1.70158; 
		if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
		return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
	},
	easeInBounce: function (t, b, c, d) {
		return c - easing.easeOutBounce (d-t, 0, c, d) + b;
	},
	easeOutBounce: function (t, b, c, d) {
		if ((t/=d) < (1/2.75)) {
			return c*(7.5625*t*t) + b;
		} else if (t < (2/2.75)) {
			return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		} else if (t < (2.5/2.75)) {
			return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		} else {
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
	},
	easeInOutBounce: function (t, b, c, d) {
		if (t < d/2) return easing.easeInBounce (t*2, 0, c, d) * .5 + b;
		return easing.easeOutBounce (t*2-d, 0, c, d) * .5 + c*.5 + b;
	}
}
`
