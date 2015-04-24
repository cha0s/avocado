
String = require './String'

describe 'String', ->

  it "can capitalize", ->

  	expect(String.capitalize 'hello').toBe 'Hello'

  it "can generate a setter name from a property name", ->

  	expect(String.setterName 'property').toBe 'setProperty'
