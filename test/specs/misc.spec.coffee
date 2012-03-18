{Smooth} = require '../../Smooth.coffee'

describe "Misc...", ->
	it 'should not modify the original config object', ->
		config = lanczosFilterSize: 2
		configCopy = {}
		configCopy[k] = v for k,v of config
		s = Smooth [1,2,3], config
		#check object equality
		expect(v).toBe configCopy[k] for own k,v of config
		expect(config[k]).toBe v for own k,v of configCopy

