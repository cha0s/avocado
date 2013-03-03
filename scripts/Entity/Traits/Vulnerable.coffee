Trait = require 'Entity/Traits/Trait'
Vector = require 'Extension/Vector'

module.exports = class extends Trait

	defaults: ->
		
		vulnerable: true
		
	actions: ->
		
		setVulnerable: (vulnerable) -> @state.vulnerable = vulnerable
		
	values: ->
		
		vulnerable: -> @state.vulnerable
		
	signals: ->
		
		harmed: (data) ->
			
			return unless (entity = data.entity)?
			return unless @state.vulnerable
			
			@state.vulnerable = false
			
#			hypotenuse = Vector.hypotenuse(
#				@entity.position()
#				entity.position()
#			)
#			
#			@entity.push Vector.scale hypotenuse, 8
			
			if @entity.hasTrait 'Visibility'
				
				isVisible = @entity.isVisible()
				
				flickerInterval = setInterval(
					=>
						@entity.setIsVisible not @entity.isVisible()
					20
				)
			
			setTimeout(
				=>
					if flickerInterval
						@entity.setIsVisible isVisible
						clearInterval flickerInterval
					@state.vulnerable = true
				750
			)
		
	