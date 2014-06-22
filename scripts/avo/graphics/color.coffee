
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'

module.exports = Color = class

	mixins = [
		Property 'red', 0
		Property 'green', 0
		Property 'blue', 0
		Property 'alpha', 1
	]
	
	constructor: (r = 255, g = 0, b = 255, a = 1) ->
		mixin.call @ for mixin in mixins
		
		@setRed r
		@setGreen g
		@setBlue b
		@setAlpha a
		
	toCss: -> "rgba(#{@red()}, #{@green()}, #{@blue()}, #{@alpha()})"
		
	FunctionExt.fastApply Mixin, [@::].concat mixins	
