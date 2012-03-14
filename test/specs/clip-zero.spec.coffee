{Smooth} = require '../../Smooth.coffee'

describe "Clip Zero", ->
	arr = [1,2,3,4]
	len = arr.length
	s = Smooth arr, clip:Smooth.CLIP_ZERO

	it 'should be zero when out of bounds', ->
		expect(s -1).toEqual 0
		expect(s -100.3).toEqual 0
		expect(s len+1).toEqual 0
		expect(s len+12.2).toEqual 0
		expect(s len+1000).toEqual 0

	it 'should leave in-bounds values untouched', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 2).toEqual arr[2]