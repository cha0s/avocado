
input = require './index'

input.Mouse =

	ButtonLeft: 1
	ButtonMiddle: 2
	ButtonRight: 3
	WheelUp: 4
	WheelDown: 5

mouseButtonMap = (button) ->

	switch button
	
		when 0 then input.Mouse.ButtonLeft
		when 1 then input.Mouse.ButtonMiddle
		when 2 then input.Mouse.ButtonRight
