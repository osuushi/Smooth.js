![Smooth.js](/osuushi/Smooth.js/wiki/images/logo-white.png)

####Table of Contents
[        What is this for?](#rm-what)<br/>
[        How do I use it?](#rm-how)<br/>
[                Configuration](#rm-config)<br/>
[                        Interpolation Methods](#rm-method)<br/>
[                        Clipping Modes](#rm-clip)<br/>
[                        Scaling](#rm-scale)<br/>
[                        Validation](#rm-valid)<br/>
[                Interpolating Vectors](#rm-vec)<br/>
[        Future Plans](#rm-future)<br/>

<a name = "rm-what" />
# What is this for?

Smooth.js takes an array of numbers or vectors and returns a parametric function that continuously interpolates
that array. Smooth.js supports several interpolation methods, and flexible options for boundary behavior.

Smooth.js is written in clean, easy-to-read CoffeeScript, and has no external dependencies. It is licensed 
under the permissive MIT license, so you can use it in just about any project.

<a name = "rm-how" />
# How do I use it?

You can compile to javascript from the Smooth.coffee source file, or 
[download the latest compiled release](https://github.com/downloads/osuushi/Smooth.js/Smooth-0.1.5.js)

Smooth.js exposes one public function, `Smooth`. The simplest use case is like this:

```js
var s = Smooth([1,2,3,4]);
console.log(s(1));			// => 2
console.log(s(1.5));		// => 2.5
```

The first line will make `s` a function that interpolates the array [1,2,3,4] as a cubic spline. the second line
will print out index 1 of the array, which is 2. The third line *interpolates* 
halfway between indexes 1 and 2 of the array, yielding 2.5

<a name = "rm-config" />
##Configuration

The `Smooth` function can take an object as an optional second argument which specifies the configuration 
options described below.

<a name = "rm-method" />
### Interpolation Methods

        (For visual illustrations of these interpolation methods see 
[the wiki](https://github.com/osuushi/Smooth.js/wiki/Interpolation-Methods))

The `method` config option specifies the interpolation method. There are three possible values for this 
option:

#### Nearest Neighbor

```js
Smooth.METHOD_NEAREST = 'nearest'
```

This interpolation method is like stair steps. The parameter is simply rounded to the nearest integer and 
that element of the array is returned.

Time complexity to interpolate a point: O(1)

#### Linear

```js
Smooth.METHOD_LINEAR = 'linear'
```

Linear interpolation creates line segments between the input points and interpolates along those segments. 
While smoother than nearest neighbor, this interpolation method produces sharp corners where the parameter is
an integer.

Time complexity to interpolate a point: O(1)

#### Cubic

```js
Smooth.METHOD_CUBIC = 'cubic'
```

This is the default interpolation method, which turns the array into a 
[cubic Hermite spline](http://en.wikipedia.org/wiki/Cubic_Hermite_spline). This method is very smooth and will
not produce sharp corners.

The cubic Hermite spline used by Smooth.js is known as a 
[cardinal spline](http://en.wikipedia.org/wiki/Cubic_hermite_spline#Cardinal_spline). This kind of spline 
allows you to choose a "tension" parameter as the `cubicTension` field of the config object. Two constants are
provided for this value: `Smooth.CUBIC_TENSION_DEFAULT` and `Smooth.CUBIC_TENSION_CATMULL_ROM`, but you can 
use any value between 0 and 1.

`Smooth.CUBIC_TENSION_CATMULL_ROM` produces a 
[Catmull-Rom spline](http://en.wikipedia.org/wiki/Cubic_hermite_spline#Catmull.E2.80.93Rom_spline), which is commonly
used for inbetweening keyframe animations. It is equal to a tension parameter of zero.

`Smooth.CUBIC_TENSION_DEFAULT` is an alias for `CUBIC_TENSION_CATMULL_ROM`.

Time complexity to interpolate a point: O(1)

#### Windowed sinc filter

```js
Smooth.METHOD_SINC = 'sinc'
```

Interpolate by applying a windowed version of the [sinc filter](http://en.wikipedia.org/wiki/Sinc_filter).

You can specify the size of the window with the `sincFilterSize` config parameter. The window will extend by
this value in either direction from the origin. This value must be a positive integer. The default is 2.

You must also provide a window function via the `sincWindow` configuration option. This function should take
one numeric parameter and return a numeric value. For example:

```js
var s = Smooth([1,2,3], {
	method: 'sinc',
	sincFilterSize: 2
	sincWindow: function(x) { return Math.exp( -x*x); }
});
```

will create a sinc filter with a Gaussian window function.

The window function is implicitly further multiplied by a rectangular window determined by sincFilterSize, so

```js
	sincWindow: function(x) { return 1; }
```

will create a sinc filter with a simple rectangular window function.

Time complexity to interpolate a point: O(N), where N = `sincFilterSize` (assuming your window function is
O(1))

#### Lanczos

```js
Smooth.METHOD_LANCZOS = 'lanczos'
```

Interpolate via [Lanczos resampling](http://en.wikipedia.org/wiki/Lanczos_resampling). Convolves the input
array by a Lanczos kernel to produce intermediate points.

The size of the Lanczos kernel can be specified via the `lanczosFilterSize` config parameter (default = 2). 
This parameter should be a positive integer.

**Note:** This filter is actually a specific case of the sinc filter. The `lanczosFilterSize` config option
is an alias for `sincFilterSize`, and the Lanczos window function is automatically created for you based on 
this parameter. 

Time complexity to interpolate a point: O(N), where N = `lanczosFilterSize`

<a name = "rm-clip" />
### Clipping modes

In addition to interpolating an array, Smooth.js allows you to specify the behavior of the output function 
when the parameter is outside the array's bounds. This also has an effect on cubic interpolation when 
interpolating near the array's bounds.

The `clip` config option specifies the clipping mode, and can take the following values:

#### Clamp

```js
Smooth.CLIP_CLAMP = 'clamp'
```

The default clipping mode; the ends of the array are simply repeated to infinity.

#### Zero

```js
Smooth.CLIP_ZERO = 'zero'
```

Outside the array bounds, the value drops to zero.

#### Periodic

```js
Smooth.CLIP_PERIODIC = 'periodic'
```

The whole array repeats infinitely in both directions. This is useful, for example, if you want values for a
looping animation.


#### Mirror

```js
Smooth.CLIP_MIRROR = 'mirror'
```

Repeats the array infinitely in both directions, reflecting each time. For example, if you applied this to 
`[1,2,3,4]` then the result would be `[1,2,3,4,3,2,1,2,3,4...]`. Useful for "loop back and forth" style 
animations, for example.

<a name = "rm-scale" />
### Scaling

The `scaleTo` config option allows you to scale the domain of the function. The default value is 0, which 
tells Smooth.js to leave the domain like the original array, so that for any integer `i`, `s(i) == arr[i]`.

Setting the `scaleTo` option to non-zero will scale the domain to that value. For example:

```js
var s = Smooth([1,2,3], { scaleTo: 1 });
console.log( s(0) );		// => 1
console.log( s(1/2) );		// => 2
console.log( s(1) );		// => 3
```

You can also provide a range for the `scaleTo` option, as an array of two numbers. This will scale the 
function to fit in that range. For example

```js
var s = Smooth([1,2,3], { scaleTo: [10,12] });
console.log( s(10) );		// => 1
console.log( s(12) );		// => 2
console.log( s(14) );		// => 3
```

When using `Smooth.CLIP_PERIODIC`, the behavior of the `scaleTo` option is slightly different; instead of
scaling to place the end of the array at the value of `scaleTo`, the value is used as the *period* of the
function.

For the sake of readability, the `period` config option is aliased to `scaleTo`. Thus:

```js
var s = Smooth([1,2,3], { period: 1, clip:Smooth.CLIP_PERIODIC });
console.log( s(0) );		// => 1
console.log( s(1/3) );		// => 2
console.log( s(2/3) );		// => 3
console.log( s(1) );		// => 1
```

<a name="rm-valid" />
###Validation

By default the input array you pass to `Smooth` will be examined thoroughly to make sure that the input is 
valid, and exceptions will be thrown if any problems are found. This can be a performance consideration if you
are dealing with large amounts of data.

This deep validation behavior can be disabled globally like so:

```js
Smooth.deepValidation = false;
```

This will cause the Smooth function to only validate the first element of each array, and only minimally.


<a name = "rm-vec" />
##Interpolating Vectors

So far all of the example code we've seen has used scalar arrays, but Smooth.js supports interpolation of 
vectors of arbitrary dimension. Simply supply the vectors as arrays. For example, this code:

```js
var points = [
	[0, 1],
	[4, 5],
	[5, 3],
	[2, 0]
];

var path = Smooth(points, {
	method: Smooth.METHOD_CUBIC, 
	clip: Smooth.CLIP_PERIODIC, 
	cubicTension: Smooth.CUBIC_TENSION_CATMULL_ROM
});
```

could be used to create a path function along which to animate a sprite in a loop.


<a name = "rm-future" />
# Future Plans

* Interpolation of non-uniform arrays (objects with arbitrary numeric indexes)
* More interpolation methods
* Custom interpolation methods (maybe)