
input = require './index'

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

input.Key =

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

keyCodeMap = (keyCode) ->

	switch keyCode

		when 8 then input.Key.Backspace
		when 9 then input.Key.Tab
		when 13 then input.Key.Enter
		when 27 then input.Key.Escape
		when 32 then input.Key.Space
#		when 33 then input.Key.ExclamationMark
#		when 34 then input.Key.QuotationMark
#		when 35 then input.Key.NumberSign
#		when 36 then input.Key.DollarSign
#		when 37 then input.Key.PercentSign
#		when 38 then input.Key.Ampersand
		when 222 then input.Key.Apostrophe
#		when 40 then input.Key.ParenthesisLeft
#		when 41 then input.Key.ParenthesisRight
#		when 42 then input.Key.Asterisk
#		when 43 then input.Key.Plus
		when 188 then input.Key.Comma
		when 189 then input.Key.Dash
		when 190 then input.Key.Period
		when 191 then input.Key.Slash

		when 48 then input.Key['0']
		when 49 then input.Key['1']
		when 50 then input.Key['2']
		when 51 then input.Key['3']
		when 52 then input.Key['4']
		when 53 then input.Key['5']
		when 54 then input.Key['6']
		when 55 then input.Key['7']
		when 56 then input.Key['8']
		when 57 then input.Key['9']

#		when 58 then input.Key.Colon
		when 186 then input.Key.Semicolon
#		when 60 then input.Key.LessThan
		when 61 then input.Key.EqualsSign
#		when 62 then input.Key.GreaterThan
#		when 63 then input.Key.QuestionMark
#		when 64 then input.Key.At

		when 65 then input.Key.A
		when 66 then input.Key.B
		when 67 then input.Key.C
		when 68 then input.Key.D
		when 69 then input.Key.E
		when 70 then input.Key.F
		when 71 then input.Key.G
		when 72 then input.Key.H
		when 73 then input.Key.I
		when 74 then input.Key.J
		when 75 then input.Key.K
		when 76 then input.Key.L
		when 77 then input.Key.M
		when 78 then input.Key.N
		when 79 then input.Key.O
		when 80 then input.Key.P
		when 81 then input.Key.Q
		when 82 then input.Key.R
		when 83 then input.Key.S
		when 84 then input.Key.T
		when 85 then input.Key.U
		when 86 then input.Key.V
		when 87 then input.Key.W
		when 88 then input.Key.X
		when 89 then input.Key.Y
		when 90 then input.Key.Z

		when 219 then input.Key.BracketLeft
		when 220 then input.Key.Backslash
		when 221 then input.Key.BracketRight
#		when 94 then input.Key.Caret
#		when 95 then input.Key.Underscore
		when 192 then input.Key.Backtick

#		when 123 then input.Key.BraceLeft

		# Lowerwhen alphabet excluded...

#		when 124 then input.Key.Pipe
#		when 125 then input.Key.BraceRight
#		when 126 then input.Key.Tilde
		when 46 then input.Key.Delete

		when 112 then input.Key.F1
		when 113 then input.Key.F2
		when 114 then input.Key.F3
		when 115 then input.Key.F4
		when 116 then input.Key.F5
		when 117 then input.Key.F6
		when 118 then input.Key.F7
		when 119 then input.Key.F8
		when 120 then input.Key.F9
		when 121 then input.Key.F10
		when 122 then input.Key.F11
		when 123 then input.Key.F12
		when 124 then input.Key.F13
		when 125 then input.Key.F14
		when 126 then input.Key.F15

		when 38 then input.Key.ArrowUp
		when 39 then input.Key.ArrowRight
		when 40 then input.Key.ArrowDown
		when 37 then input.Key.ArrowLeft

		when 45 then input.Key.Insert
		when 36 then input.Key.Home
		when 35 then input.Key.End
		when 33 then input.Key.PageUp
		when 34 then input.Key.PageDown

		when 17 then input.Key.ControlLeft
		when 18 then input.Key.AltLeft
		when 16 then input.Key.ShiftLeft
		when 91 then input.Key.SystemLeft
		when 17 then input.Key.ControlRight
		when 18 then input.Key.AltRight
		when 16 then input.Key.ShiftRight
		when 91 then input.Key.SystemRight
		when 93 then input.Key.Menu
