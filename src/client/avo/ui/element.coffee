
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

  append: (other) ->

    element = if other instanceof AvoElement
      other.appendTo this
    else
      $(other).appendTo this

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
      return @element[key] unless value?
      @element[key] = value
    else
      @attr k, v for own k, v of key

    return this

  clear: ->
    i = 0
    while (element = @element[i++])?
      element.parentNode.removeChild element if element.parentNode?

  clone: (deep) -> $ @element.cloneNode deep

  css: (key, value) ->
    return this unless key?

    if key instanceof String or typeof key is 'string'
      return @element.style[key] unless value?
      @element.style[key] = value
    else
      @css k, v for own k, v of key

    return this

  data: (key, value) ->
    return this unless key?

    if key instanceof String or typeof key is 'string'
      return @element.dataset[key] unless value?
      @element.dataset[key] = value
    else
      @data k, v for own k, v of key

    return this

  hasClass: (class_) ->
    return false unless @element.className

    for class__ in @element.className.trim().split ' '
      return true if class_ is class__

    return false

  html: (html) ->

    if html?

      @element.innerHTML = html
      return this

    else

      return @element.innerHTML

  on: (event_, fn) ->

    @element.addEventListener event_, fn

    return this

  removeAttr: (key) ->

    @element.removeAttribute key
    return this

  removeClass: (classes) ->
    return this unless @element.className
    classMap = {}

    for class_ in @element.className.trim().split ' '
      continue unless class_
      classMap[class_] = true

    for class_ in classes.split ' '
      delete classMap[class_] if classMap[class_]?

    unless @element.className = Object.keys(classMap).join ' '
      @element.removeAttribute 'class'

    return this
