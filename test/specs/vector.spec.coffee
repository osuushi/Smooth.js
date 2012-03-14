{Smooth} = require '../../Smooth.coffee'

{distance} = require './util.coffee'

describe 'Vector', ->
	it 'should approximate a unit circle', ->
		{SQRT2, SQRT1_2} = Math
		SQRT3 = Math.sqrt(3)
		circle_points = [
			#Quadrant I
			[1, 0]
			[SQRT3/2, 1/2]
			[SQRT1_2, SQRT1_2]
			[1/2, SQRT3/2]

			#Quadrant II
			[0, 1]
			[-1/2, SQRT3/2]
			[-SQRT1_2, SQRT1_2]
			[-SQRT3/2, 1/2]

			#Quadrant III
			[-1, 0]
			[-SQRT3/2, -1/2]
			[-SQRT1_2, -SQRT1_2]
			[-1/2, -SQRT3/2]

			#Quadrant IV
			[0, -1]
			[1/2, -SQRT3/2]
			[SQRT1_2, -SQRT1_2]
			[SQRT3/2, -1/2]
		]
		#Make into a function
		circle = Smooth circle_points, period:1, clip:Smooth.CLIP_PERIODIC

		#Integrate arc length
		l = 0
		start = [1,0]
		for t in [0..1] by .0001
			end = circle t
			l += distance start, end
			start = end

		#Result length should be approximately 2*pi
		expect(l).toBeCloseTo 2*Math.PI

