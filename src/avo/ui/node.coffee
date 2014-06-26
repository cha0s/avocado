
_ = require 'avo/vendor/underscore'
$ = require 'avo/vendor/jquery'
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'
Transition = require 'avo/mixin/transition'
window_ = require 'avo/graphics/window'

module.exports = class DomNode
	
	mixins = [
		EventEmitter
		Transition
	]
	
	constructor: (htmlOrElement) ->
		mixin.call this for mixin in mixins
		
		if _.isString htmlOrElement
			@_node = window.document.createElement 'div'
			@_node.innerHTML = htmlOrElement
		else
			@_node = htmlOrElement
		
		@_node.style.position = 'absolute'
			
	FunctionExt.fastApply Mixin, [@::].concat mixins
	
	destroy: -> 
	
		container = window_.container()
		container.removeChild @_node
		
	addClass: (classNames) -> $(@_node).addClass classNames
		
	element: -> @_node
	
	find: (selector) -> $(@_node).find selector
	
	hasClass: (className) -> $(@_node).hasClass classNames

	removeClass: (classNames) -> $(@_node).removeClass classNames
		
	hide: -> @_node.style.display = 'none'
	
	show: -> @_node.style.display = 'block'
	
	setIsSelectable: (isSelectable) ->
		
		if isSelectable

			@removeClass 'unselectable'
			@_node.removeAttribute 'unselectable'
			@_node.removeAttribute 'onselectstart'
			
			@_node.style.cursor = 'auto'

		else

			@addClass 'unselectable'
			@_node.unselectable = 'yes'
			@_node.onselectstart = 'return false;'
			
			@_node.style.cursor = 'default'
	
	_parsePx: (px) ->
		parsed = px.match /^-?[0-9.]+/
		return 0 unless parsed?
		parseFloat parsed
	
	x: -> @_parsePx @_node.style.left
	setX: (x) -> @_node.style.left = "#{x}px"
	
	y: -> @_parsePx @_node.style.top
	setY: (y) -> @_node.style.top = "#{y}px"
	
	position: -> [@x(), @y()]
	setPosition: (position) ->
		@setX position[0]
		@setY position[1]
		
	opacity: -> @_node.style.opacity
	setOpacity: (opacity) -> @_node.style.opacity = opacity
	
	setScale: (scaleX, scaleY = scaleX) ->
		for prefix in ['', '-moz-', '-ms-', '-webkit-', '-o-']
			@_node.style["#{prefix}transform"] = "scale(#{
				scaleX
			}, #{
				scaleY
			})"
