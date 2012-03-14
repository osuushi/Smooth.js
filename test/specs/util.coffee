### Helper code for tests ###


#Approximate derivative function with some delta value
exports.deriv = (f, delta = 0.0001) -> 
	(t) -> ((f t+delta) - (f t))/delta

exports.distance = (a, b) ->
	sqDist = 0
	l = a.length
	sqDist += Math.pow a[i]-b[i], 2 for i in [0...l]
	return Math.sqrt sqDist
