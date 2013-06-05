
Graphics = require 'Graphics'

Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = RasterFont = class
	
	@load = (uri) ->
		Graphics.Image.load(uri).then (image) =>
			font = new RasterFont()
			font.image_ = image
			font.charSize_ = Vector.div font.image_.size(), [16, 16]
			font.charOffset_ = for i in [0...256]
				[
					font.charSize_[0] * Math.floor(i % 16)
					font.charSize_[1] * Math.floor(i / 16)
				]
			font
	
	textWidth: (text) -> text.length * @charSize_[0]
	
	textHeight: (text) -> @charSize_[1]
	
	textSize: (text) -> [
		@textWidth text
		@textHeight text
	]
	
	render: (
		position
		text
		destination
		clip
		alpha = 1
		effect = null
	) ->
		
		# TODO test for empty text
		return unless text
		
		clip ?= Rectangle.compose [0, 0], @textSize text
		
		# Get the current area of the Image to render, based on the current
		# character, as well as the frame size.
		rect = (character) => Rectangle.compose(
			@charOffset_[character]
			[@charSize_[0], @charSize_[1]]
		)
		
		position = Vector.sub position, Rectangle.position clip
		clip = Rectangle.translated clip, position
		
		# Pre-calc the length. Iterate over the string's characters.
		for i in [0...text.length]
		
			effectedLocation = Vector.copy position
			effectedLocation = Vector.add(
				effectedLocation
				effect.apply i
			) if effect?
			
			# Move right the width of the font.
			position[0] += @charSize_[0]
			
			# The bounding rect of the character to render.
			charRect = Rectangle.compose effectedLocation, @charSize_
			
			# Don't render the character if it isn't in the clipping area.
			intersection = Rectangle.intersection charRect, clip
			continue if Rectangle.isNull intersection
			
			offset = Vector.sub(
				Rectangle.position intersection
				Rectangle.position charRect
			)
			
			# Render the character.
			sprite = new Graphics.Sprite()
			sprite.setSource @image_
			sprite.setPosition Vector.add effectedLocation, offset
			sprite.setAlpha alpha
			sprite.setSourceRectangle Rectangle.compose(
				Vector.add(
					offset
					Rectangle.position rect text.charCodeAt i
				)
				Rectangle.size intersection
			)
			sprite.renderTo destination

		undefined
