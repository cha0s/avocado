
Node = require 'avo/ui/node'
ui = require 'avo/ui'

exports.createNode = (canvas) ->

  uiErrorNode = new Node(
    """
<div class="container">
  <div class="centered">
    <h1>
      <span class="error-type"></span>:
      <span class="error-message"></span>
    </h1>
    <ul class="backtrace"></ul>
  </div>
</div>
"""
  )

  uiErrorNode.hide()
  uiErrorNode.setPosition [0, 0]
  uiErrorNode.addClass 'error'
  canvas.uiContainer().appendChild uiErrorNode.element()

  ui.addCssText """

.error {
  z-index: 10000;
}

.container {
  background-color: rgba(0, 0, 0, .8);
  color: white;
  font-family: monospace;
  width: 100%;
  height: 100%;
  display: table;
}

.centered {
  display: table-cell;
  vertical-align: middle;
}

.centered h1 {
  font-size: 30px;
  text-align: center;
}

.centered h1 .error-type {
  color: red;
}

.centered h1 .error-message {
  color: yellow;
}

.centered .backtrace {
  margin: auto;
  width: 80%
}

"""

  return uiErrorNode
