
FunctionExt = require 'avo/extension/function'
MathExt = require 'avo/extension/math'
Rectangle = require 'avo/extension/rectangle'
Vector = require 'avo/extension/vector'

Container = require 'avo/graphics/container'

EventEmitter = require 'avo/mixin/eventEmitter'
Lfo = require 'avo/mixin/lfo'
Mixin = require 'avo/mixin'
Property = require 'avo/mixin/property'
VectorMixin = require 'avo/mixin/vector'

module.exports = class Camera

  mixins = [
    EventEmitter
    Lfo

    Property 'easing', default: 7

    AreaProperty = VectorMixin(
      'area', 'areaX', 'areaY'
      areaX: default: 0
      areaY: default: 0
    )

    VectorMixin(
      'offset', 'offsetX', 'offsetY'
      offsetX: default: 0
      offsetY: default: 0
    )

    VectorMixin 'position'

    VectorMixin 'size', 'width', 'height'
  ]

  constructor: ->
    mixin.call this for mixin in mixins

    @_container = new Container()

    @_easingSpeed = 500
    @_entity = null
    @_inputLock = false
    @_lock = [false, false]
    @_projectedPosition = [0, 0]
    @_transitionResult = null

    @_container.on 'scaleChanged', @_updateProjection, this
    @_container.on 'positionChanged', => @emit 'containerPositionChanged'
    @on ['offsetChanged', 'positionChanged'], @_updateProjection, this

  FunctionExt.fastApply Mixin, [@::].concat mixins

  addChild: (child) -> @_container.addChild child

  container: -> @_container

  projectedPosition: -> @_projectedPosition

  rectangle: -> Rectangle.compose @position(), @size()

  setArea: (area) ->
    AreaProperty::setArea.call this, area

    @_lock = [false, false]

    center = Vector.scale Vector.sub(@size(), area), .5

    if area[0] <= @width()
      @_projectedPosition[0] = center[0]
      @_lock[0] = true

    if area[1] <= @height()
      @_projectedPosition[1] = center[1]
      @_lock[1] = true

  snapTo: (position) ->

    @setPosition position
    @_updateProjection()
    @_container.setPosition @_projectedPosition

  trackEntity: (entity) ->
    @_entity?.off '.camera'

    return unless (@_entity = entity)?

    @setPosition @_entity.position()

    @_entity.on 'positionChanged.camera', (position) ->
      @setPosition @_entity.position()
    , this

  tick: (elapsed) ->
    position = @_container.position()

    return if Vector.equals position, @_projectedPosition

    return @_container.setPosition @_projectedPosition if @easing() is 0

    hypotenuse = Vector.hypotenuse @_projectedPosition, position

    k = (elapsed / 1000) * 512
    distance = Vector.cartesianDistance position, @_projectedPosition
    k = if distance >= 1 then k * (distance / Math.pow(2, @easing())) else k
    projection = Vector.add position, Vector.scale hypotenuse, k

    overshot = Vector.overshot projection, hypotenuse, @_projectedPosition
    if overshot[0] or overshot[1]
      @_container.setPosition @_projectedPosition
    else
      @_container.setPosition projection

  _updateProjection: ->

    position = Vector.mul @position(), @_container.scale()
    position = Vector.sub position, Vector.scale @size(), .5
    position = Vector.clamp(
      position, [0, 0], Vector.sub(
        Vector.mul @_container.scale(), @area()
        @size()
      )
    )
    position = Vector.scale position, -1
    position = Vector.add position, @offset()

    @_projectedPosition[0] = position[0] unless @_lock[0]
    @_projectedPosition[1] = position[1] unless @_lock[1]
