{Smooth} = require '../../Smooth.coffee'

{deriv} = require './util.coffee'

describe 'Sinc Filter Interpolator', ->
	arr = [1,3,-2,8]
	describe 'Gaussian window', ->
		s = Smooth arr, method: 'sinc', sincWindow: (x) -> Math.exp -x*x

		it 'should be close to array at integer indexes', ->
			for i in [0...arr.length]
				expect(s i).toBeCloseTo arr[i]

		it 'should be continuous everywhere', ->
			delta = 0.00001
			for i in [-1..arr.length] by 1/64
				expect(s i).toBeCloseTo s(i-delta), 0

		it 'should be differentiable everywhere', ->
			delta = 0.00001
			ds = deriv s
			for i in [-1..arr.length] by 1/64
				expect(ds i).toBeCloseTo ds(i-delta), 0

	describe 'Circular window', ->
		s = Smooth arr, method: 'sinc', sincWindow: (x) -> Math.sqrt(1 - x*x/4)

		it 'should be close to array at integer indexes', ->
			for i in [0...arr.length]
				expect(s i).toBeCloseTo arr[i]

		it 'should be continuous everywhere', ->
			delta = 0.00001
			for i in [-1..arr.length] by 1/64
				expect(s i).toBeCloseTo s(i-delta), 0

		it 'should be differentiable everywhere', ->
			delta = 0.00001
			ds = deriv s
			for i in [-1..arr.length] by 1/64
				expect(ds i).toBeCloseTo ds(i-delta), 0
