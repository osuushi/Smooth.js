{Smooth} = require '../../Smooth.coffee'
util = require './util'

describe "Smooth function properties...", ->
	it 'should save a shallow copy of the config passed in by the user', ->
		config = cubicTension: 1, method: 'cubic', clip: 'zero'
		s = Smooth [1,2,3], config
		expect(s.config).toEqual config

	it 'should save the domain correctly', ->
		expect((Smooth [1,1,1]).domain).toEqual [0, 2]
		expect((Smooth [1,1,1,1], clip:'periodic').domain).toEqual [0, 4]
		expect((Smooth [1,1,1], scaleTo:2).domain).toEqual [0, 2]
		expect((Smooth [1,1,1], scaleTo:[1,5]).domain).toEqual [1, 5]
		expect((Smooth [1,1,1], clip:'periodic', scaleTo:[1,5]).domain).toEqual [1, 5]
		expect((Smooth [1,1,1], scaleTo:[5,1]).domain).toEqual [1, 5]

	it 'should save the count correctly', ->
		expect(Smooth([1,1,3]).count).toBe 3
		expect(Smooth([1,2,3], scaleTo:5).count).toBe 3
	
	it 'should save the dimension correctly', ->
		expect(Smooth([1,2,3]).dimension).toBe 'scalar'
		expect(Smooth([[1],[2],[3]]).dimension).toBe 1
		expect(Smooth([[1,2],[2,3],[3,4]]).dimension).toBe 2
