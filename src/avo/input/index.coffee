
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

mixins = [
	EventEmitter
]

input = module.exports

FunctionExt.fastApply Mixin, [input].concat mixins

mixin.call input for mixin in mixins

require "./#{sub}" for sub in ['gamepad', 'key', 'mouse', 'movement']
