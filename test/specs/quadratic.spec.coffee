{Smooth} = require '../../Smooth.coffee'

{deriv} = require './util.coffee'


describe 'Quadratic Interpolator', ->

	arr = [1,3,-2,8,3]
	s = Smooth arr, method:Smooth.METHOD_QUADRATIC, cubicTension: Smooth.CATMULL_ROM

	it 'should match integer indexes', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 2).toEqual arr[2]
		expect(s 3).toEqual arr[3]
		expect(s 4).toEqual arr[4]

	it 'should have little change in derivative near integers', ->
		ds = deriv s
		delta = 0.00001
		expect(ds 1 + delta).toBeCloseTo ds 1 - delta
		expect(ds 2 + delta).toBeCloseTo ds 2 - delta
		expect(ds 3 + delta).toBeCloseTo ds 3 - delta
