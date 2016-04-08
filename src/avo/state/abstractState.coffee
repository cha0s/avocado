# # AbstractState
# The abstract class which all states in the Avocado engine extend.
#
# Avocado is always in a State, except during the initialization phase, and
# shortly before exiting the engine.
#
# States will never be destroyed during the lifecycle of the engine. Remember
# this, as it means that **no child objects will be garbage collected unless
# you delete them explicitly!**
Promise = require 'avo/vendor/bluebird'

EventEmitter = require 'avo/mixin/eventEmitter'
FunctionExt = require 'avo/extension/function'
Mixin = require 'avo/mixin'

module.exports = class AbstractState

  mixins = [
    EventEmitter
  ]

  FunctionExt.fastApply Mixin, [@::].concat mixins

  # ##### constructor
  # Make sure to call this from your subclass.
  constructor: -> mixin.call @ for mixin in mixins

  # ##### initialize
  # When the state is first loaded, initialize is called. This is used to
  # initialize the State. You can load resources that are to remain as
  # persistent for the life of the application.
  #
  # If you need to do something asynchronously, return a promise. If you
  # don't return a promise, the engine will continue immediately.
  initialize: (canvas) ->

  # ##### enter
  # When the State is entered by the engine, enter is called. You can use
  # this to register input handlers and load resources that should be loaded
  # every time this State is entered by the engine. After this State is
  # entered, it becomes the active State.
  #
  # If you need to do something asynchronously, return a promise. If you
  # don't return a promise, the engine will continue immediately.
  enter: (args, previousStateName) ->

  render: (renderer) ->

  # ##### tick
  # Called repeatedly by the engine while this State is the active
  # State. This is where the game is updated. You might run your enemy
  # behavior logic here, for instance.
  tick: ->

  # ##### leave
  # Called when the engine loads another State. This gives the State an
  # opportunity to clean up any resources loaded or input handlers loaded
  # or registered in enter().
  leave: ->
