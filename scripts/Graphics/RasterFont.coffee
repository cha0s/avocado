
DisplayCommand = require 'Graphics/DisplayCommand'
Image = require('Graphics').Image
Q = require 'Utility/Q'
Rectangle = require 'Extension/Rectangle'
Vector = require 'Extension/Vector'

module.exports = RasterFont = class
	
	@load = (uri) ->
		Image.load(uri).then (image) =>
			font = new RasterFont()
			font.image_ = image
			font.charSize_ = Vector.div font.image_.size(), [256, 1]
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
		clip = Rectangle.compose [0, 0], @textSize text
		alpha = 255
		effect = null
	) ->
		
		# Get the current area of the Image to render, based on the current
		# character, as well as the frame size.
		rect = (character) => [
			character * @charSize_[0], 0
			@charSize_[0], @charSize_[1]
		]
		
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
			@image_.render(
				Vector.add effectedLocation, offset
				destination
				alpha
				Image.DrawMode_Blend
				Rectangle.compose(
					Vector.add(
						offset
						Rectangle.position rect text.charCodeAt i
					)
					Rectangle.size intersection
				)
			)

		undefined
