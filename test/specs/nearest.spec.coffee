{Smooth} = require '../../Smooth.coffee'

{deriv} = require './util.coffee'

describe 'Nearest Neighbor Interpolator', ->
	arr = [1,2,3,4]
	s = Smooth arr, method:Smooth.METHOD_NEAREST

	it 'should match integer indexes', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 2).toEqual arr[2]
		expect(s 3).toEqual arr[3]

	it 'should round fractional parameter', ->
		expect(s 0.1).toEqual arr[0]
		expect(s 1.9).toEqual arr[2]
		expect(s 2.2).toEqual arr[2]
		expect(s 2.8).toEqual arr[3]
	
	it 'should have zero derivatives where fraction != .5', ->
		expect(deriv(s) 1).toBeCloseTo 0
		expect(deriv(s) 1.1).toBeCloseTo 0
		expect(deriv(s) 1.9).toBeCloseTo 0
		expect(deriv(s) 3.2).toBeCloseTo 0