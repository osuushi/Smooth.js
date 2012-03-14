{Smooth} = require '../../Smooth.coffee'

describe "Clip Mirror", ->
	arr = [1,2,3,4]
	len = arr.length
	s = Smooth arr, clip:Smooth.CLIP_MIRROR

	it 'should reflect across the origin', ->
		expect(s -1).toEqual arr[1]
		expect(s -2).toEqual arr[2]
		expect(s -3).toEqual arr[3]
	
	it 'should produce a predictable pattern', ->
		mirrorArray = arr.concat (arr[i] for i in [len-2...0]) #create pattern to repeat
		expect( (s i for i in [0...20]).join() )
			.toBe (mirrorArray[i%mirrorArray.length] for i in [0...20]).join()


	it 'should leave in-bounds values untouched', ->
		expect(s 0).toEqual arr[0]
		expect(s 1).toEqual arr[1]
		expect(s 3).toEqual arr[3]