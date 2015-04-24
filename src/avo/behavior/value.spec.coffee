
Behavior = require './index'

describe 'Behavior', ->

  it "values can be accessed", ->

  	cv = 0
  	context =
  		test:
  			get: -> cv
  			set: (cv_) -> cv = cv_

  	value = new Behavior.Value()
  	value.fromObject

  		selector: 'test:get'
  		args: [
  			[
  			]
  		]

  	expect(value.get context).toBe 0

  	cv = 69
  	expect(value.get context).toBe 69
