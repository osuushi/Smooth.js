### Helper code for tests ###


#Approximate derivative function with some delta value
exports.deriv = (f, delta = 0.001) -> 
	(t) -> ((f t+delta) - (f t))/delta