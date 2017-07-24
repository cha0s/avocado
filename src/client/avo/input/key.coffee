
Vector = require 'avo/extension/vector'

exports.attachListeners = (input) ->

  keyDownFlags = {}
  keyUpDelays = {}

  # I really hate the keyup delay magic here, but unfortunately GTK on linux
  # is really really stupid with key repeats.
  #
  # See: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent#Auto-repeat_on_some_GTK_environments_such_as_Ubuntu_9.4
  window?.addEventListener 'keydown', (event) ->
    event ?= window.event

    if keyDownFlags[event.keyCode]

      if keyUpDelays[event.keyCode]

        clearTimeout keyUpDelays[event.keyCode]
        delete keyUpDelays[event.keyCode]

      return

    keyDownFlags[event.keyCode] = true

    input.emit(
      'keyDown'
      keyCode: event.keyCode
      # repeat: event.repeat
      # event
    )

    return

  window?.addEventListener 'keyup', (event) ->
    event ?= window.event

    keyUpDelays[event.keyCode] = setTimeout ->

      delete keyUpDelays[event.keyCode]
      delete keyDownFlags[event.keyCode]

      input.emit(
        'keyUp'
        keyCode: event.keyCode
        # repeat: event.repeat
        # event
      )

    , 80

    return

  window?.addEventListener 'blur', (event) ->
    event ?= window.event

    clearTimeout keyUpDelays[keyCode] for keyCode of keyUpDelays

    input.emit(
      'keyUp'
      keyCode: parseInt keyCode
      # event
    ) for keyCode of keyDownFlags

    keyDownFlags = {}
    keyUpDelays = {}

    return

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

    F1: 112
    F2: 113
    F3: 114
    F4: 115
    F5: 116
    F6: 117
    F7: 118
    F8: 119
    F9: 120
    F10: 121
    F11: 122
    F12: 123
    F13: 124
    F14: 125
    F15: 126

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
