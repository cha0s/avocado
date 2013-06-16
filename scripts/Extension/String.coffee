
_ = require 'Utility/underscore'

# String operations.

# **String** is a utility class to help with string operations.
module.exports = String = 
	
	# From a name, get a setter name. e.g.
	# 
	#     avocado> String.setterName 'width'
	#     'setWidth'
	setterName: (name) -> "set#{String.capitalize name}"
	
	# Capitalize the first character in the string. e.g.
	# 
	#     avocado> String.capitalize 'ruben'
	#     'Ruben'
	capitalize: (string) ->
		
		string.substr(0, 1).toUpperCase() + string.substr 1
		
	formatInteger: (integer, atLeast = 1) ->
		
		integerString = "#{integer}"
		for i in [0...atLeast - integerString.length]
			integerString = '0' + integerString
		integerString
