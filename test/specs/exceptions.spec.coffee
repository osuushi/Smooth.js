{Smooth} = require '../../Smooth.coffee'

describe 'Exceptions', ->
	it 'should throw for invalid methods', ->
		expect(-> Smooth [1,2], method: 'lanscoz').toThrow "Invalid method: lanscoz"
		expect(-> Smooth [1,2], method: 'Cubic').toThrow "Invalid method: Cubic"

	it 'should throw for invalid clipping mode', ->
		expect(-> Smooth [1,2], clip: 'mirorr').toThrow "Invalid clip: mirorr"
		expect(-> Smooth [1,2], clip: 'Linear').toThrow "Invalid clip: Linear"

	it 'should throw for invalid arrays', ->
		expect(-> Smooth []).toThrow 'Array must have at least two elements'
		expect(-> Smooth [0]).toThrow 'Array must have at least two elements'

	it 'should throw for bad input', ->
		expect(-> Smooth ['a','b']).toThrow 'Invalid element type: [object String]'
		expect(-> Smooth [(->), (->)]).toThrow 'Invalid element type: [object Function]'
		expect(-> Smooth [[], []]).toThrow 'Vectors must be non-empty'
