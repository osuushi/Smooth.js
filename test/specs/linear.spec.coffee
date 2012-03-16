{Smooth} = require '../../Smooth.coffee'

{deriv} = require './util.coffee'


describe 'Linear Interpolator', ->
	arr = [1,4,3,8]
	s = Smooth arr, method:Smooth.METHOD_LINEAR

	it 'should match integer indexes', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 2).toEqual arr[2]
		expect(s 3).toEqual arr[3]

	it 'should have arithmetic mean for midpoints', ->
		expect(s 0.5).toBeCloseTo (arr[0]+arr[1])/2
		expect(s 1.5).toBeCloseTo (arr[1]+arr[2])/2
		expect(s 2.5).toBeCloseTo (arr[2]+arr[3])/2

	it 'should have derivatives equal to point differences', ->
		expect(deriv(s) 0.2).toBeCloseTo arr[1] - arr[0]
		expect(deriv(s) 0.8).toBeCloseTo arr[1] - arr[0]
		expect(deriv(s) 1.4).toBeCloseTo arr[2] - arr[1]
		expect(deriv(s) 2.7).toBeCloseTo arr[3] - arr[2]

	it 'should repeat when periodic', ->
		p = Smooth arr, method:'linear', clip: 'periodic', scaleTo: 1
		for i in [-2..2] by 1/16
			expect(p i).toEqual p i - Math.floor i