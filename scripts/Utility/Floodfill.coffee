module.exports = class
	
	nodeStack: {}
	pastNodes: {}
	
	constructor: (@totalArea, @unitArea) ->
		
		@nodeStack = {}
		@pastNodes = {}
		
	value: (x, y) ->
	setValue: (x, y, value) ->
	valueEquals: (l, r) -> l is r
	
	markNode: (x, y) ->
		
		node = [x, y]
		
		return if @pastNodes[node]
		
		@pastNodes[node] = true
		@nodeStack[node] = node 
		
	nextNode: ->
		
		break for own key of @nodeStack
		
		return unless key?
		
		node = @nodeStack[key]
		
		delete @nodeStack[key]
		
		node
	
	fillAt: (x, y, fillValue) ->
		
		@pastNodes = {}
		startValue = @value x, y

		# Early out if the starting value is the same as the fill value.
		return if @valueEquals startValue, fillValue

		spanLeft = 0
		spanRight = 0

		y1 = 0

		@markNode x, y
		
		while node = @nextNode()
			[x, y] = node

			y1 = y
			while y1 >= 0 and @valueEquals startValue, @value x, y1
				y1 -= @unitArea[1]

			y1 += @unitArea[1]

			spanLeft = 0
			spanRight = 0

			while y1 <= @totalArea[1] - @unitArea[1] and @valueEquals startValue, @value x, y1 

				@setValue x, y1, fillValue

				if x > @unitArea[0] - 1

					if 0 is spanLeft and @valueEquals startValue, @value x - @unitArea[0], y1

						@markNode x - @unitArea[0], y1
						spanLeft = 1
					
					else if spanLeft isnt 0 and not @valueEquals startValue, @value x - @unitArea[0], y1

						spanLeft = 0

				if x < @totalArea[0] - @unitArea[0]

					if 0 is spanRight and @valueEquals startValue, @value x + @unitArea[0], y1

						@markNode x + @unitArea[0], y1
						spanRight = 1
					
					else if spanRight isnt 0 and @valueEquals startValue, @value x + @unitArea[0], y1

						spanRight = 0

				y1 += @unitArea[1]
