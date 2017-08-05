
module.exports = $ = class AvoElement

  @create: (tagName) -> $ window.document.createElement tagName

  constructor: (element) ->
    return new AvoElement element unless this instanceof AvoElement

    @element = element

  addClass: (classes) ->
    classMap = {}

    for class_ in classes.trim().split ' '
      continue unless class_
      classMap[class_] = true

    for class_ in @element.className.trim().split ' '
      continue unless class_
      classMap[class_] = true

    @element.className = Object.keys(classMap).join ' '

    return this

  appendTo: (other) ->

    element = if other instanceof AvoElement
      other.element
    else
      other

    element.appendChild @element

    return this

  attr: (key, value) ->
    return this unless key?

    if key instanceof String or typeof key is 'string'
      @element[key] = value
    else
      @attr k, v for own k, v of key

    return this

  clone: (deep) -> $ @element.cloneNode deep

  hasClass: (class_) ->
    return false unless @element.className

    for class__ in @element.className.trim().split ' '
      return true if class_ is class__

    return false

  on: (event_, fn) ->

    @element.addEventListener event_, fn

    return this

  removeClass: (classes) ->
    return this unless @element.className
    classMap = {}

    for class_ in @element.className.trim().split ' '
      continue unless class_
      classMap[class_] = true

    for class_ in classes.split ' '
      delete classMap[class_] if classMap[class_]?

    @element.className = Object.keys(classMap).join ' '

    return this
