
EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

mixins = [
	EventEmitter
]

input = module.exports 

FunctionExt.fastApply Mixin, [input].concat mixins

mixin.call input for mixin in mixins

input.KeyCode =

	Backspace: 8
	Tab: 9
	Enter: 13
	Escape: 27
	Space: 32
	ExclamationMark: 33
	QuotationMark: 34
	NumberSign: 35
	DollarSign: 36
	PercentSign: 37
	Ampersand: 38
	Apostrophe: 39
	ParenthesisLeft: 40
	ParenthesisRight: 41
	Asterisk: 42
	Plus: 43
	Comma: 44
	Dash: 45
	Period: 46
	Slash: 47
	
	0: 48
	1: 49
	2: 50
	3: 51
	4: 52
	5: 53
	6: 54
	7: 55
	8: 56
	9: 57
	
	Colon: 58
	Semicolon: 59
	LessThan: 60
	EqualsSign: 61
	GreaterThan: 62
	QuestionMark: 63
	At: 64
	
	A: 65
	B: 66
	C: 67
	D: 68
	E: 69
	F: 70
	G: 71
	H: 72
	I: 73
	J: 74
	K: 75
	L: 76
	M: 77
	N: 78
	O: 79
	P: 80
	Q: 81
	R: 82
	S: 83
	T: 84
	U: 85
	V: 86
	W: 87
	X: 88
	Y: 89
	Z: 90
	
	BracketLeft: 91
	Backslash: 92
	BracketRight: 93
	Caret: 94
	Underscore: 95
	Backtick: 96
	
	# Lowercase alphabet excluded...
	
	BraceLeft: 123
	Pipe: 124
	BraceRight: 125
	Tilde: 126
	Delete: 127
	
	F1: 256
	F2: 257
	F3: 258
	F4: 259
	F5: 260
	F6: 261
	F7: 262
	F8: 263
	F9: 264
	F10: 265
	F11: 266
	F12: 267
	F13: 268
	F14: 269
	F15: 270
	
	ArrowUp: 271
	ArrowRight: 272
	ArrowDown: 273
	ArrowLeft: 274
	
	Insert: 275
	Home: 276
	End: 277
	PageUp: 278
	PageDown: 279
	
	ControlLeft: 280
	AltLeft: 281
	ShiftLeft: 282
	SystemLeft: 283
	ControlRight: 284
	AltRight: 285
	ShiftRight: 286
	SystemRight: 287
	Menu: 288
	
	Pause: 289

input.Mouse =

	ButtonLeft: 1
	ButtonMiddle: 2
	ButtonRight: 3
	WheelUp: 4
	WheelDown: 5

keyDownFlags = {}

window.addEventListener 'keydown', (event) ->
	event ?= window.event
	
	repeat = keyDownFlags[event.keyCode] is true
	keyDownFlags[event.keyCode] = true
	
	input.emit(
		'keyDown'
		keyCode: keyCodeMap event.keyCode
		preventDefault: -> event.preventDefault()
		repeat: repeat
	)
	
	return

window.addEventListener 'keyup', (event) ->
	event ?= window.event
	
	delete keyDownFlags[event.keyCode]
	
	input.emit(
		'keyUp'
		keyCode: keyCodeMap event.keyCode
		preventDefault: -> event.preventDefault()
	)
	
	return

window.addEventListener 'blur', ->
	
	input.emit(
		'keyUp'
		keyCode: keyCodeMap keyCode
	) for keyCode of keyDownFlags
		
	keyDownFlags = {}

keyCodeMap = (keyCode) ->
	
	switch keyCode
	
		when 8 then input.KeyCode.Backspace
		when 9 then input.KeyCode.Tab
		when 13 then input.KeyCode.Enter
		when 27 then input.KeyCode.Escape
		when 32 then input.KeyCode.Space
#		when 33 then input.KeyCode.ExclamationMark
#		when 34 then input.KeyCode.QuotationMark
#		when 35 then input.KeyCode.NumberSign
#		when 36 then input.KeyCode.DollarSign
#		when 37 then input.KeyCode.PercentSign
#		when 38 then input.KeyCode.Ampersand
		when 222 then input.KeyCode.Apostrophe
#		when 40 then input.KeyCode.ParenthesisLeft
#		when 41 then input.KeyCode.ParenthesisRight
#		when 42 then input.KeyCode.Asterisk
#		when 43 then input.KeyCode.Plus
		when 188 then input.KeyCode.Comma
		when 189 then input.KeyCode.Dash
		when 190 then input.KeyCode.Period
		when 191 then input.KeyCode.Slash
	
		when 48 then input.KeyCode['0']
		when 49 then input.KeyCode['1']
		when 50 then input.KeyCode['2']
		when 51 then input.KeyCode['3']
		when 52 then input.KeyCode['4']
		when 53 then input.KeyCode['5']
		when 54 then input.KeyCode['6']
		when 55 then input.KeyCode['7']
		when 56 then input.KeyCode['8']
		when 57 then input.KeyCode['9']
	
#		when 58 then input.KeyCode.Colon
		when 186 then input.KeyCode.Semicolon
#		when 60 then input.KeyCode.LessThan
		when 61 then input.KeyCode.EqualsSign
#		when 62 then input.KeyCode.GreaterThan
#		when 63 then input.KeyCode.QuestionMark
#		when 64 then input.KeyCode.At
	
		when 65 then input.KeyCode.A
		when 66 then input.KeyCode.B
		when 67 then input.KeyCode.C
		when 68 then input.KeyCode.D
		when 69 then input.KeyCode.E
		when 70 then input.KeyCode.F
		when 71 then input.KeyCode.G
		when 72 then input.KeyCode.H
		when 73 then input.KeyCode.I
		when 74 then input.KeyCode.J
		when 75 then input.KeyCode.K
		when 76 then input.KeyCode.L
		when 77 then input.KeyCode.M
		when 78 then input.KeyCode.N
		when 79 then input.KeyCode.O
		when 80 then input.KeyCode.P
		when 81 then input.KeyCode.Q
		when 82 then input.KeyCode.R
		when 83 then input.KeyCode.S
		when 84 then input.KeyCode.T
		when 85 then input.KeyCode.U
		when 86 then input.KeyCode.V
		when 87 then input.KeyCode.W
		when 88 then input.KeyCode.X
		when 89 then input.KeyCode.Y
		when 90 then input.KeyCode.Z
	
		when 219 then input.KeyCode.BracketLeft
		when 220 then input.KeyCode.Backslash
		when 221 then input.KeyCode.BracketRight
#		when 94 then input.KeyCode.Caret
#		when 95 then input.KeyCode.Underscore
		when 192 then input.KeyCode.Backtick
	
#		when 123 then input.KeyCode.BraceLeft
		
		# Lowerwhen alphabet excluded...
		
#		when 124 then input.KeyCode.Pipe
#		when 125 then input.KeyCode.BraceRight
#		when 126 then input.KeyCode.Tilde
		when 46 then input.KeyCode.Delete
	
		when 112 then input.KeyCode.F1
		when 113 then input.KeyCode.F2
		when 114 then input.KeyCode.F3
		when 115 then input.KeyCode.F4
		when 116 then input.KeyCode.F5
		when 117 then input.KeyCode.F6
		when 118 then input.KeyCode.F7
		when 119 then input.KeyCode.F8
		when 120 then input.KeyCode.F9
		when 121 then input.KeyCode.F10
		when 122 then input.KeyCode.F11
		when 123 then input.KeyCode.F12
		when 124 then input.KeyCode.F13
		when 125 then input.KeyCode.F14
		when 126 then input.KeyCode.F15
	
		when 38 then input.KeyCode.ArrowUp
		when 39 then input.KeyCode.ArrowRight
		when 40 then input.KeyCode.ArrowDown
		when 37 then input.KeyCode.ArrowLeft
	
		when 45 then input.KeyCode.Insert
		when 36 then input.KeyCode.Home
		when 35 then input.KeyCode.End
		when 33 then input.KeyCode.PageUp
		when 34 then input.KeyCode.PageDown
	
		when 17 then input.KeyCode.ControlLeft
		when 18 then input.KeyCode.AltLeft
		when 16 then input.KeyCode.ShiftLeft
		when 91 then input.KeyCode.SystemLeft
		when 17 then input.KeyCode.ControlRight
		when 18 then input.KeyCode.AltRight
		when 16 then input.KeyCode.ShiftRight
		when 91 then input.KeyCode.SystemRight
		when 93 then input.KeyCode.Menu

mouseButtonMap = (button) ->

	switch button
	
		when 0 then input.Mouse.ButtonLeft
		when 1 then input.Mouse.ButtonMiddle
		when 2 then input.Mouse.ButtonRight
