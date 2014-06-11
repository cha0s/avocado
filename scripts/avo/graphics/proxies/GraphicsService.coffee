
exports.proxy = ({GraphicsService}) ->
	
	# Blend mode constants.
	# 
	# * `GraphicsService.BlendMode_Replace`: Write over any graphics under this 
	# image when rendering.
	# * `GraphicsService.BlendMode_Blend`: ***(default)*** Blend the image with any 
	# graphics underneath using alpha pixel values.
	GraphicsService.BlendMode_Replace = 0
	GraphicsService.BlendMode_Blend   = 1
