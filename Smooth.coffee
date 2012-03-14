###
Smooth.js version 0.1.2

Turn arrays into smooth functions.

Copyright 2012 Spencer Cohen
Licensed under MIT license (see "Smooth.js MIT license.txt")

###


###Constants (these are accessible by Smooth.WHATEVER in user space)###
Enum = 
	###Interpolation methods###
	METHOD_NEAREST: 0 #Rounds to nearest whole index
	METHOD_LINEAR: 1 
	METHOD_QUADRATIC: 2
	METHOD_CUBIC: 3 # Default: cubic interpolation

	###Input clipping modes###
	CLIP_CLAMP: 0 # Default: clamp to [0, arr.length-1]
	CLIP_ZERO: 1 # When out of bounds, clip to zero
	CLIP_PERIODIC: 2 # Repeat the array infinitely in either direction
	CLIP_MIRROR: 3 # Repeat infinitely in either direction, flipping each time

	### Constants for control over the cubic interpolation tension ###
	CUBIC_TENSION_DEFAULT: 0 # Default tension value
	CUBIC_TENSION_CATMULL_ROM: 0

defaultConfig = 
	method: Enum.METHOD_CUBIC						#The interpolation method
	cubicTension: Enum.CUBIC_TENSION_DEFAULT		#The cubic tension parameter
	clip: Enum.CLIP_CLAMP 							#The clipping mode
	scaleTo: 0										#The scale to value (0 means don't scale)


###Index clipping functions###
clipClamp = (i, n) -> Math.max 0, Math.min i, n - 1

clipPeriodic = (i, n) ->
	i = i % n #wrap
	i += n if i < 0 #if negative, wrap back around
	i

clipMirror = (i, n) ->
	period = 2*(n - 1) #period of index mirroring function
	i = clipPeriodic i, period
	i = period - i if i > n - 1 #flip when out of bounds 
	i


###
Abstract scalar interpolation class which provides common functionality for all interpolators

Subclasses must override interpolate().
###

class AbstractInterpolator

	constructor: (array, config) ->
		@array = array.slice 0 #copy the array
		@length = @array.length #cache length

		#Set the clipping helper method
		@clipHelper = switch config.clip
			when Enum.CLIP_CLAMP 
				@clipHelperClamp
			when Enum.CLIP_ZERO
				@clipHelperZero
			when Enum.CLIP_PERIODIC
				@clipHelperPeriodic
			when Enum.CLIP_MIRROR
				@clipHelperMirror
			else
				err = new Error
				err.message = "The clipping mode #{config.clip} is invalid."
				throw err

    # Get input array value at i, applying the clipping method
	getClippedInput: (i) ->
		#Normal behavior for indexes within bounds
		if 0 <= i < @length
			@array[i]
		else
			@clipHelper i

	clipHelperClamp: (i) -> @array[clipClamp i, @length]

	clipHelperZero: (i) -> 0

	clipHelperPeriodic: (i) -> @array[clipPeriodic i, @length]

	clipHelperMirror: (i) -> @array[clipMirror i, @length]

	interpolate: (t) ->
		err = new Error
		err.message = 'Subclasses of AbstractInterpolator must override the interpolate() method.'
		throw err


#Nearest neighbor interpolator (round to whole index)
class NearestInterpolator extends AbstractInterpolator
	interpolate: (t) -> @getClippedInput Math.round t


#Linear interpolator (first order Bezier)
class LinearInterpolator extends AbstractInterpolator
	interpolate: (t) ->
		k = Math.floor t
		a = @getClippedInput k
		b = @getClippedInput k+1
		#Translate t to interpolate between k and k+1
		t -= k
		return (1-t)*a + (t)*b


class CubicInterpolator extends AbstractInterpolator
	constructor: (array, config)->
		@tangentFactor = 1 - Math.max 0, Math.min 1, config.cubicTension
		super

	# Cardinal spline with tension 0.5)
	getTangent: (k) -> @tangentFactor*(@getClippedInput(k + 1) - @getClippedInput(k - 1))/2

	interpolate: (t) ->
		k = Math.floor t
		m = [(@getTangent k), (@getTangent k+1)] #get tangents
		p = [(@getClippedInput k), (@getClippedInput k+1)] #get points
		#Translate t to interpolate between k and k+1
		t -= k
		t2 = t*t #t^2
		t3 = t*t2 #t^3
		#Apply cubic hermite spline formula
		return (2*t3 - 3*t2 + 1)*p[0] + (t3 - 2*t2 + t)*m[0] + (-2*t3 + 3*t2)*p[1] + (t3 - t2)*m[1]


class QuadraticInterpolator extends AbstractInterpolator
	constructor: (array, config) ->
		super
		###Precalculate tangents###
		tangents = @calculateTangents array[1] - array[0]
		if config.clip is Enum.CLIP_PERIODIC
			#For periodic clipping, use a second pass to smooth the seam between cycles
			tangents = @calculateTangents tangents[tangents.length-1]

		@tangents = Smooth tangents, clip:config.clip, method:Enum.METHOD_NEAREST


	calculateTangents: (initialTangent) ->
		tangents = [initialTangent]
		for i in [1...@length]
			a = @array[i - 1]
			b = @array[i]
			m = tangents[i-1]
			tangents[i] = 2*(b - a) - m
		return tangents


	interpolate: (t) ->
		k = Math.floor t
		m = @tangents k
		start = @getClippedInput k
		end = @getClippedInput k + 1
		a = end - start - m
		b = m
		c = start
		t -= k
		return a*t*t + b*t + c




#Extract a column from a two dimensional array
getColumn = (arr, i) -> (row[i] for row in arr)


#Take a function with one parameter and apply a scale factor to its parameter
makeScaledFunction = (f, scaleFactor) ->
	if scaleFactor is 1
		f #don't wrap the function unecessarily
	else 
		(t) -> f(t*scaleFactor)

Smooth = (arr, config = {}) ->
	#Alias 'period' to 'scaleTo'
	config.scaleTo ?= config.period

	config[k] ?= v for own k,v of defaultConfig #fill in defaults

	#Get the interpolator class according to the configuration
	interpolatorClass = switch config.method
		when Enum.METHOD_NEAREST then NearestInterpolator
		when Enum.METHOD_LINEAR then LinearInterpolator
		when Enum.METHOD_CUBIC then CubicInterpolator
		when Enum.METHOD_QUADRATIC then QuadraticInterpolator
		else
			err = new Error
			err.message = "The interpolation method #{config.method} is invalid."
			throw err

	#Make sure there's at least one element in the input array
	if arr.length < 2
		err = new Error
		err.message = 'Array must have at least two elements.'
		throw err

	#See what type of data we're dealing with
	dataType = Object.prototype.toString.call arr[0]

	smoothFunc = switch dataType
			when '[object Number]' #scalar
				interpolator = new interpolatorClass arr, config
				(t) -> interpolator.interpolate t

			when '[object Array]' # vector
				interpolators = (new interpolatorClass(getColumn(arr, i), config) for i in [0...arr[0].length])
				(t) -> (interpolator.interpolate(t) for interpolator in interpolators)

			else 
				err = new Error
				err.message = 'Invalid element type: #{dataType}'
				throw err

	if config.scaleTo 
		#Because periodic functions repeat, we scale the domain to extend to the beginning of the next cycle.
		if config.clip is Smooth.CLIP_PERIODIC
			baseScale = arr.length
		else #for other clipping types, we scale the domain to extend exactly to the end of the input array
			baseScale = arr.length - 1
		smoothFunc = makeScaledFunction smoothFunc, baseScale/config.scaleTo 

	return smoothFunc


#Copy enums to Smooth
Smooth[k] = v for own k,v of Enum


root = exports ? window
root.Smooth = Smooth
