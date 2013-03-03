Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	defaults: ->
		
		isHarming: true
		
	actions: ->
	
		setIsHarming: (isHarming) -> @state.isHarming = isHarming
		
	values: ->
		
		isHarming: -> @state.isHarming
	
	signals: ->
		
		collisionStart: (self, other) ->
			
			return unless self?.entity?
			return unless other?.entity?
			
			return unless @state.isHarming
			
			other.entity.emit 'harmed', self
