
Vector = require 'avo/extension/vector'

exports.attachListeners = (input) ->

  keyDownFlags = {}

  window.addEventListener 'keydown', (event) ->
    event ?= window.event

    repeat = keyDownFlags[event.keyCode] is true
    keyDownFlags[event.keyCode] = true

    input.emit(
      'keyDown'
      keyCode: event.keyCode
      repeat: repeat
      event
    )

    return

  window.addEventListener 'keyup', (event) ->
    event ?= window.event

    delete keyDownFlags[event.keyCode]

    input.emit(
      'keyUp'
      keyCode: event.keyCode
      event
    )

    return

  window.addEventListener 'blur', (event) ->
    event ?= window.event

    input.emit(
      'keyUp'
      keyCode: keyCode
      event
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

    ArrowUp: 38
    ArrowRight: 39
    ArrowDown: 40
    ArrowLeft: 37

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
