{Smooth} = require '../../Smooth.coffee'

{distance} = require './util.coffee'

describe 'Vector', ->
	it 'should approximate a unit circle', ->
		{sin, cos, PI} = Math
		circle_points = ([cos(PI*t), sin(PI*t)] for t in [0...2] by 1/6)
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

