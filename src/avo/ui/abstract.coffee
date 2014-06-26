
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

module.exports = class UiAbstract
	
	mixins = [
		EventEmitter
	]

	constructor: (@_node) ->
		mixin.call this for mixin in mixins

	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	hide: -> @_node.hide()
	
	show: -> @_node.show()
	
