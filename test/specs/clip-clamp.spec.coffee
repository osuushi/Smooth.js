{Smooth} = require '../../Smooth.coffee'

describe "Clip Clamp", ->
	arr = [1,2,3,4]
	len = arr.length
	s = Smooth arr, clip:Smooth.CLIP_CLAMP

	it 'should extend first value to negative infinity', ->
		expect(s -1).toEqual arr[0]
		expect(s -5.8).toEqual arr[0]
		expect(s -100.3).toEqual arr[0]

	it 'should extend last value to positive infinity', ->
		expect(s len+1).toEqual arr[len-1]
		expect(s len+12.2).toEqual arr[len-1]
		expect(s len+1000).toEqual arr[len-1]

	it 'should leave in-bounds values untouched', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 2).toEqual arr[2]