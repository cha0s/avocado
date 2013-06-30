
Graphics = require 'Graphics'

# Blend mode constants.
# 
# * `GraphicsService.BlendMode_Replace`: Write over any graphics under this 
# image when rendering.
# * `GraphicsService.BlendMode_Blend`: ***(default)*** Blend the image with any 
# graphics underneath using alpha pixel values.
Graphics.GraphicsService.BlendMode_Replace = 0
Graphics.GraphicsService.BlendMode_Blend   = 1
