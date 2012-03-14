{Smooth} = require '../../Smooth.coffee'

describe "Clip Periodic", ->
	arr = [1,2,3,4]
	len = arr.length
	s = Smooth arr, clip:Smooth.CLIP_PERIODIC

	it 'should repeat the same value for a shift by any integer multiple of the array length', ->
		expect(s 0 - 98*len).toEqual arr[0]
		expect(s 1 + 12*len).toEqual arr[1]
		expect(s 2 - 13*len).toEqual arr[2]
		expect(s 3 + 47*len).toEqual arr[3]

	it 'should leave in-bounds values untouched', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 3).toEqual arr[3]