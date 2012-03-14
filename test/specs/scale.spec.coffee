{Smooth} = require '../../Smooth.coffee'

describe "Scale to...", ->
	arr = [1,2,3,4]

	it 'should scale to [0,1]', ->
		s = Smooth arr, scaleTo: 1
		expect(s 0).toBeCloseTo arr[0]
		expect(s 1/3).toBeCloseTo arr[1]
		expect(s 2/3).toBeCloseTo arr[2]
		expect(s 1).toBeCloseTo arr[3]

	it 'should scale to [0, length-1] with no change from unscaled', ->
		s_noscale = Smooth arr
		s_scale = Smooth arr, scaleTo: arr.length-1

		expect(s_scale 0).toBeCloseTo s_noscale 0
		expect(s_scale 2).toBeCloseTo s_noscale 2
		expect(s_scale 2.5).toBeCloseTo s_noscale 2.5
		expect(s_scale 3).toBeCloseTo s_noscale 3

	it 'should scale to [0, 9]', ->
		s = Smooth arr, scaleTo: 9
		expect(s 0).toBeCloseTo arr[0]
		expect(s 3).toBeCloseTo arr[1]
		expect(s 6).toBeCloseTo arr[2]
		expect(s 9).toBeCloseTo arr[3]

	it 'should reflect when scaling to -(length-1)', ->
		s = Smooth arr, scaleTo: -(arr.length - 1)
		expect(s 0).toBeCloseTo arr[0]
		expect(s -1).toBeCloseTo arr[1]
		expect(s -2).toBeCloseTo arr[2]
		expect(s -3).toBeCloseTo arr[3]

	it 'should scale to the next cycle for periodic functions', ->
		s = Smooth arr, scaleTo: 1, clip:Smooth.CLIP_PERIODIC