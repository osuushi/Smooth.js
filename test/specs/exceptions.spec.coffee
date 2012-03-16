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
		expect(-> Smooth ['a','b']).toThrow 'Invalid element type: String'
		expect(-> Smooth [(->), (->)]).toThrow 'Invalid element type: Function'
		expect(-> Smooth [[], []]).toThrow 'Vectors must be non-empty'

	it 'should throw for sinc filter with no window', ->
		expect(-> Smooth [1,2], method:'sinc').toThrow 'No sincWindow provided'

	describe 'With deep validation on...', ->
		it 'should throw for bad input deep inside the input', ->
			expect(-> Smooth [1,2,'a']).toThrow 'NaN in Smooth() input'
			expect(-> Smooth [1,2,'3']).toThrow 'Non-number in Smooth() input'
			expect(-> Smooth [1,2, Infinity]).toThrow 'Infinity in Smooth() input'

			expect(-> Smooth [[1],[2],['a']]).toThrow 'NaN in Smooth() input'
			expect(-> Smooth [[1],[2],['3']]).toThrow 'Non-number in Smooth() input'
			expect(-> Smooth [[1],[2], [Infinity]]).toThrow 'Infinity in Smooth() input'

			expect(-> Smooth [[1], 1]).toThrow 'Non-vector in Smooth() input'
			expect(-> Smooth [[1], [1,2]]).toThrow 'Inconsistent dimension in Smooth() input'

	describe 'With deep validation off...', ->
		it 'should not throw for bad input deep inside the input', ->
			expect(Smooth [1,2,'a'], deepValidation:false).toBeTruthy()
			expect(Smooth [1,2,'3'], deepValidation:false).toBeTruthy()
			expect(Smooth [1,2, Infinity], deepValidation:false).toBeTruthy()

			expect(Smooth [[1],[2],['a']], deepValidation:false).toBeTruthy()
			expect(Smooth [[1],[2],['3']], deepValidation:false).toBeTruthy()
			expect(Smooth [[1],[2], [Infinity]], deepValidation:false).toBeTruthy()

			expect(Smooth [[1], 1], deepValidation:false).toBeTruthy()
			expect(Smooth [[1], [1,2]], deepValidation:false).toBeTruthy()
