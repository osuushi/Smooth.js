{Smooth} = require '../../Smooth.coffee'
util = require './util'

describe "Misc...", ->
	it 'should not modify the original config object', ->
		config = lanczosFilterSize: 2
		configCopy = util.shallowCopy config
		s = Smooth [1,2,3], config
		#check object equality
		expect(config).toEqual configCopy

