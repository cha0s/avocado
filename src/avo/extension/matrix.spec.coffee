
Matrix = require './Matrix'

describe 'Matrix', ->

  it "can inspect size", ->

  	matrix = [[0, 0], [0, 0], [0, 0], [0, 0]]

  	expect(Matrix.size matrix).toBe 8
  	expect(Matrix.sizeVector matrix).toEqual [2, 4]

  it "can test equality", ->

  	l = [[0, 0], [0, 0], [0, 0], [0, 0]]
  	r = [[0, 0], [0, 0], [0, 0], [0, 0]]

  	expect(Matrix.equals l, r).toBe true

  it "can make deep copies", ->

  	matrix = [[1], [2], [3]]
  	matrix2 = Matrix.copy matrix

  	expect(matrix).toEqual matrix2

  	matrix[0][0] = 4

  	expect(matrix).not.toEqual matrix2
