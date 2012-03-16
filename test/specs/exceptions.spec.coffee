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

	it 'should throw for invalid scaleTo', ->
		expect(-> Smooth [1,2], scaleTo:[1]).toThrow 'scaleTo param must be number or array of two numbers'
		expect(-> Smooth [1,2], scaleTo:[1,2,3]).toThrow 'scaleTo param must be number or array of two numbers'
		expect(-> Smooth [1,2], scaleTo:'a').toThrow 'scaleTo param must be number or array of two numbers'
		expect(-> Smooth [1,2], scaleTo:[1,'x']).toThrow 'scaleTo param must be number or array of two numbers'
		expect(-> Smooth [1,2], scaleTo:Infinity).toThrow 'scaleTo param must be number or array of two numbers'

	describe 'With deep validation on...', ->
		it 'should throw for bad input deep inside the input', ->
			Smooth.deepValidation = true
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
			Smooth.deepValidation = false
			expect(Smooth [1,2,'a']).toBeTruthy()
			expect(Smooth [1,2,'3']).toBeTruthy()
			expect(Smooth [1,2, Infinity]).toBeTruthy()

			expect(Smooth [[1],[2],['a']]).toBeTruthy()
			expect(Smooth [[1],[2],['3']]).toBeTruthy()
			expect(Smooth [[1],[2], [Infinity]]).toBeTruthy()

			expect(Smooth [[1], 1]).toBeTruthy()
			expect(Smooth [[1], [1,2]]).toBeTruthy()

