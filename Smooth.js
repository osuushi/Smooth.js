/*
 * decaffeinate suggestions:
 * DS001: Remove Babel/TypeScript constructor workaround
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS202: Simplify dynamic range loops
 * DS203: Remove `|| {}` from converted for-own loops
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
/*
Smooth.js version 0.1.7

Turn arrays into smooth functions.

Copyright 2012 Spencer Cohen
Licensed under MIT license (see "Smooth.js MIT license.txt")

*/


/*Constants (these are accessible by Smooth.WHATEVER in user space)*/
const Enum = { 
	/*Interpolation methods*/
	METHOD_NEAREST: 'nearest', //Rounds to nearest whole index
	METHOD_LINEAR: 'linear', 
	METHOD_CUBIC: 'cubic', // Default: cubic interpolation
	METHOD_LANCZOS: 'lanczos',
	METHOD_SINC: 'sinc',

	/*Input clipping modes*/
	CLIP_CLAMP: 'clamp', // Default: clamp to [0, arr.length-1]
	CLIP_ZERO: 'zero', // When out of bounds, clip to zero
	CLIP_PERIODIC: 'periodic', // Repeat the array infinitely in either direction
	CLIP_MIRROR: 'mirror', // Repeat infinitely in either direction, flipping each time

	/* Constants for control over the cubic interpolation tension */
	CUBIC_TENSION_DEFAULT: 0, // Default tension value
	CUBIC_TENSION_CATMULL_ROM: 0
};


const defaultConfig = { 
	method: Enum.METHOD_CUBIC,                       //The interpolation method
	
	cubicTension: Enum.CUBIC_TENSION_DEFAULT,        //The cubic tension parameter
	
	clip: Enum.CLIP_CLAMP,                           //The clipping mode
	
	scaleTo: 0,                                      //The scale-to value (0 means don't scale) (can also be a range)
	
	sincFilterSize: 2,                               //The size of the sinc filter kernel (must be an integer)

	sincWindow: undefined                           //The window function for the sinc filter
};

/*Index clipping functions*/
const clipClamp = (i, n) => Math.max(0, Math.min(i, n - 1));

const clipPeriodic = function(i, n) {
	i = i % n; //wrap
	if (i < 0) { i += n; } //if negative, wrap back around
	return i;
};

const clipMirror = function(i, n) {
	const period = 2*(n - 1); //period of index mirroring function
	i = clipPeriodic(i, period);
	if (i > (n - 1)) { i = period - i; } //flip when out of bounds 
	return i;
};


/*
Abstract scalar interpolation class which provides common functionality for all interpolators

Subclasses must override interpolate().
*/

class AbstractInterpolator {

	constructor(array, config) {
		this.array = array.slice(0); //copy the array
		this.length = this.array.length; //cache length

		//Set the clipping helper method
		if (!(this.clipHelper = {
			clamp: this.clipHelperClamp,
			zero: this.clipHelperZero,
			periodic: this.clipHelperPeriodic,
			mirror: this.clipHelperMirror
		}[config.clip])) { throw `Invalid clip: ${config.clip}`; }
	}


    // Get input array value at i, applying the clipping method
	getClippedInput(i) {
		//Normal behavior for indexes within bounds
		if (0 <= i && i < this.length) {
			return this.array[i];
		} else {
			return this.clipHelper(i);
		}
	}

	clipHelperClamp(i) { return this.array[clipClamp(i, this.length)]; }

	clipHelperZero(i) { return 0; }

	clipHelperPeriodic(i) { return this.array[clipPeriodic(i, this.length)]; }

	clipHelperMirror(i) { return this.array[clipMirror(i, this.length)]; }

	interpolate(t) { throw 'Subclasses of AbstractInterpolator must override the interpolate() method.'; }
}


//Nearest neighbor interpolator (round to whole index)
class NearestInterpolator extends AbstractInterpolator {
	interpolate(t) { return this.getClippedInput(Math.round(t)); }
}


//Linear interpolator (first order Bezier)
class LinearInterpolator extends AbstractInterpolator {
	interpolate(t) {
		const k = Math.floor(t);
		//Translate t to interpolate between k and k+1
		t -= k;
		return ((1-t)*this.getClippedInput(k)) + ((t)*this.getClippedInput(k+1));
	}
}


class CubicInterpolator extends AbstractInterpolator {
	constructor(array, config){
		//clamp cubic tension to [0,1] range
		{
		  // Hack: trick Babel/TypeScript into allowing this before super.
		  if (false) { super(); }
		  let thisFn = (() => { return this; }).toString();
		  let thisName = thisFn.match(/return (?:_assertThisInitialized\()*(\w+)\)*;/)[1];
		  eval(`${thisName} = this;`);
		}
		this.tangentFactor = 1 - Math.max(0, Math.min(1, config.cubicTension));
		super(...arguments);
	}

	// Cardinal spline with tension 0.5)
	getTangent(k) { return (this.tangentFactor*(this.getClippedInput(k + 1) - this.getClippedInput(k - 1)))/2; }

	interpolate(t) {
		const k = Math.floor(t);
		const m = [(this.getTangent(k)), (this.getTangent(k+1))]; //get tangents
		const p = [(this.getClippedInput(k)), (this.getClippedInput(k+1))]; //get points
		//Translate t to interpolate between k and k+1
		t -= k;
		const t2 = t*t; //t^2
		const t3 = t*t2; //t^3
		//Apply cubic hermite spline formula
		return ((((2*t3) - (3*t2)) + 1)*p[0]) + (((t3 - (2*t2)) + t)*m[0]) + (((-2*t3) + (3*t2))*p[1]) + ((t3 - t2)*m[1]);
	}
}

const {sin, PI} = Math;
//Normalized sinc function
const sinc = function(x) { if (x === 0) { return 1; } else { return sin(PI*x)/(PI*x); } };

//Make a lanczos window function for a given filter size 'a'
const makeLanczosWindow = a => x => sinc(x/a);

//Make a sinc kernel function by multiplying the sinc function by a window function
const makeSincKernel = window => x => sinc(x)*window(x);

class SincFilterInterpolator extends AbstractInterpolator {
	constructor(array, config) {
		super(...arguments);
		//Create the lanczos kernel function
		this.a = config.sincFilterSize;

		//Cannot make sinc filter without a window function
		if (!config.sincWindow) { throw 'No sincWindow provided'; }
		//Window the sinc function to make the kernel
		this.kernel = makeSincKernel(config.sincWindow);
	}

	interpolate(t) {
		const k = Math.floor(t);
		//Convolve with Lanczos kernel
		let sum = 0;
		for (let start = (k - this.a) + 1, n = start, end = k + this.a, asc = start <= end; asc ? n <= end : n >= end; asc ? n++ : n--) { sum += this.kernel(t - n)*this.getClippedInput(n); }
		return sum;
	}
}


//Extract a column from a two dimensional array
const getColumn = (arr, i) => Array.from(arr).map((row) => row[i]);


//Take a function with one parameter and apply a scale factor to its parameter
const makeScaledFunction = function(f, baseScale, scaleRange) {
	if (scaleRange.join === '0,1') {
		return f; //don't wrap the function unecessarily
	} else { 
		const scaleFactor = baseScale/(scaleRange[1] - scaleRange[0]);
		const translation = scaleRange[0];
		return t => f(scaleFactor*(t - translation));
	}
};


const getType = x => Object.prototype.toString.call(x).slice(('[object '.length), -1);

//Throw exception if input is not a number
const validateNumber = function(n) {
	if (isNaN(n)) { throw 'NaN in Smooth() input'; }
	if (getType(n) !== 'Number') { throw 'Non-number in Smooth() input'; }
	if (!isFinite(n)) { throw 'Infinity in Smooth() input'; }
};
		

//Throw an exception if input is not a vector of numbers which is the correct length
const validateVector = function(v, dimension) {
	if (getType(v) !== 'Array') { throw 'Non-vector in Smooth() input'; }
	if (v.length !== dimension) { throw 'Inconsistent dimension in Smooth() input'; }
	for (let n of Array.from(v)) { validateNumber(n); }
};

const isValidNumber = n => (getType(n) === 'Number') && isFinite(n) && !isNaN(n);

const normalizeScaleTo = function(s) {
	const invalidErr = "scaleTo param must be number or array of two numbers";
	switch (getType(s)) {
		case 'Number':
			if (!isValidNumber(s)) { throw invalidErr; }
			s = [0, s];
			break;
		case 'Array':
			if (s.length !== 2) { throw invalidErr; }
			if (!isValidNumber(s[0]) || !isValidNumber(s[1])) { throw invalidErr; }
			break;
		default: throw invalidErr;
	}
	return s;
};

const shallowCopy = function(obj) {
	const copy = {};
	for (let k of Object.keys(obj || {})) { const v = obj[k]; copy[k] = v; }
	return copy;
};

var Smooth = function(arr, config) {
	//Properties to copy to the function once it is created
	let baseDomainEnd, interpolatorClass, k;
	let v;
	if (config == null) { config = {}; }
	const properties = {};
	//Make a copy of the config object to modify
	config = shallowCopy(config);

	//Make another copy of the config object to save to the function
	properties.config = shallowCopy(config);

	//Alias 'period' to 'scaleTo'
	if (config.scaleTo == null) { config.scaleTo = config.period; }

	//Alias lanczosFilterSize to sincFilterSize
	if (config.sincFilterSize == null) { config.sincFilterSize = config.lanczosFilterSize; }

	for (k of Object.keys(defaultConfig || {})) { v = defaultConfig[k]; if (config[k] == null) { config[k] = v; } } //fill in defaults

	//Get the interpolator class according to the configuration
	if (!(interpolatorClass = {
			nearest: NearestInterpolator,
			linear: LinearInterpolator,
			cubic: CubicInterpolator,
			lanczos: SincFilterInterpolator, //lanczos is a specific case of sinc filter
			sinc: SincFilterInterpolator
	}[config.method])) { throw `Invalid method: ${config.method}`; }

	if (config.method === 'lanczos') {
		//Setup lanczos window
		config.sincWindow = makeLanczosWindow(config.sincFilterSize);
	}


	//Make sure there's at least one element in the input array
	if (arr.length < 2) { throw 'Array must have at least two elements'; }

	//save count property
	properties.count = arr.length;

	//See what type of data we're dealing with

	let smoothFunc = (() => { let dimension;
	switch (getType(arr[0])) {
			case 'Number': //scalar
				properties.dimension = 'scalar';
				//Validate all input if deep validation is on
				if (Smooth.deepValidation) { for (let n of Array.from(arr)) { validateNumber(n); } }
				//Create the interpolator
				var interpolator = new interpolatorClass(arr, config);
				//make function that runs the interpolator
				return t => interpolator.interpolate(t);

			case 'Array': // vector
				properties.dimension = (dimension = arr[0].length);
				if (!dimension) { throw 'Vectors must be non-empty'; }
				//Validate all input if deep validation is on
				if (Smooth.deepValidation) { for (v of Array.from(arr)) { validateVector(v, dimension); } }
				//Create interpolator for each column
				var interpolators = (__range__(0, dimension, false).map((i) => new interpolatorClass(getColumn(arr, i), config)));
				//make function that runs the interpolators and puts them into an array
				return t => (() => {
					const result = [];
					for (interpolator of Array.from(interpolators)) { 						result.push(interpolator.interpolate(t));
					}
					return result;
				})() ;

			default: throw `Invalid element type: ${getType(arr[0])}`;
	} })();

	// Determine the end of the original function's domain
	if (config.clip === 'periodic') { baseDomainEnd = arr.length; //after last element for periodic
	} else { baseDomainEnd = arr.length - 1; } //at last element for non-periodic

	if (!config.scaleTo) { config.scaleTo = baseDomainEnd; } //default scales to the end of the original domain for no effect
	
	properties.domain = normalizeScaleTo(config.scaleTo);
	smoothFunc = makeScaledFunction(smoothFunc, baseDomainEnd, properties.domain);
	properties.domain.sort();

	/*copy properties*/
	for (k of Object.keys(properties || {})) { v = properties[k]; smoothFunc[k] = v; }

	return smoothFunc;
};

//Copy enums to Smooth
for (let k of Object.keys(Enum || {})) { const v = Enum[k]; Smooth[k] = v; }

Smooth.deepValidation = true;

(typeof exports !== 'undefined' && exports !== null ? exports : window).Smooth = Smooth;

function __range__(left, right, inclusive) {
  let range = [];
  let ascending = left < right;
  let end = !inclusive ? right : ascending ? right + 1 : right - 1;
  for (let i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
    range.push(i);
  }
  return range;
}
