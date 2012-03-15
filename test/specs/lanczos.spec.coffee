{Smooth} = require '../../Smooth.coffee'

{deriv} = require './util.coffee'

describe 'Lanczos Interpolator', ->
	arr = [1,3,-2,8]
	s = Smooth arr, method: 'lanczos'

	it 'should be close to array at integer indexes', ->
		for i in [0...arr.length]
			expect(s i).toBeCloseTo arr[i]

	it 'should be continuous everywhere', ->
		delta = 0.00001
		for i in [-1..arr.length] by 1/64
			expect(s i).toBeCloseTo s(i+delta), 0

	it 'should be differentiable everywhere', ->
		delta = 0.00001
		ds = deriv s
		for i in [-1..arr.length] by 1/64
			expect(ds i).toBeCloseTo ds(i+delta), 0
