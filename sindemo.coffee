###
sindemo

Sample and cubic interpolate the sin function, then print out max and average error.
###

{Smooth} = require './Smooth'

s = (Math.sin 2*Math.PI*x for x in [0...1] by 1/8)


#Scale the function
smooth_sin = ((f) ->
	scaleVal = 0.5*s.length/Math.PI
	return (x) -> f x*scaleVal
) Smooth s, method:Smooth.METHOD_CUBIC, clip:Smooth.CLIP_PERIODIC

totalError = 0
count = 0
maxError = 0
for x in [-10..10] by .001
	error = Math.abs Math.sin(x) - smooth_sin(x)
	maxError = Math.max error, maxError
	totalError += error
	count++

console.log "Max Error:\t #{(100*maxError).toFixed(10)}%"
console.log "Average Error:\t #{(100*totalError/count).toFixed(10)}%"