####Table of Contents
[        What is this for?](#rm-what)<br/>
[        How do I use it?](#rm-how)<br/>
[                Configuration](#rm-config)<br/>
[                        Interpolation Methods](#rm-method)<br/>
[                        Clipping Modes](#rm-clip)<br/>
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

Smooth.js exposes one public function, `Smooth`. The simplest use case is like this:

```js
var s = Smooth([1,2,3,4]);
console.log(s(1));			// 2
console.log(s(1.5));		// 2.5
```

The first line will make `s` a function that interpolates the array [1,2,3] as a cubic spline. the second line
will print out index 1 of the array, which is 2. The third line *interpolates* 
halfway between indexes 1 and 2 of the array, yielding 2.5

<a name = "rm-config" />
##Configuration

The `Smooth` function can take an object as an optional second argument. Currently, this object supports two
options.

<a name = "rm-method" />
### Interpolation Methods

The `method` config option specifies the interpolation method. There are three possible values for this 
option:

#### Nearest Neighbor

```js
Smooth.METHOD_NEAREST
```

This interpolation method is like stair steps. The parameter is simply rounded to the nearest integer and 
that element of the array is returned.

#### Linear

```js
Smooth.METHOD_LINEAR
```

Linear interpolation creates line segments between the input points and interpolates along those segments. 
While smoother than nearest neighbor, this interpolation method produces sharp corners where the parameter is
an integer.

#### Cubic

```js
Smooth.METHOD_CUBIC
```

This is the default interpolation method, which turns the array into a 
[cubic Hermite spline](http://en.wikipedia.org/wiki/Cubic_Hermite_spline). This method is very smooth and will
not produce sharp corners.

(Specifically, Smooth.js uses a
[cardinal spline](http://en.wikipedia.org/wiki/Cardinal_spline#Cardinal_spline) with a tension of 0.5)

<a name = "rm-clip" />
### Clipping modes

In addition to interpolating an array, Smooth.js allows you to specify the behavior of the output function 
when the parameter is outside the array's bounds. This also has an effect on cubic interpolation when 
interpolating near the array's bounds.

The `clip` config option specifies the clipping mode, and can take the following values:

#### Clamp

```js
Smooth.CLIP_CLAMP
```

The default clipping mode; the ends of the array are simply repeated to infinity.

#### Zero

```js
Smooth.CLIP_ZERO
```

Outside the array bounds, the value drops to zero.

#### Periodic

```js
Smooth.CLIP_PERIODIC
```

The whole array repeats infinitely in both directions. This is useful, for example, if you want values for a
looping animation.


#### Mirror

```js
Smooth.CLIP_MIRROR
```

Repeats the array infinitely in both directions, reflecting each time. For example, if you applied this to 
`[1,2,3,4]` then the result would be `[1,2,3,4,3,2,1,2,3,4...]`. Useful for "loop back and forth" style 
animations, for example.

<a name = "rm-vec" />
##Interpolating Vectors

So far all of the example code we've seen has used scalar arrays, but Smooth.js supports interpolation of 
vectors of arbitrary dimension. Simply supply the vectors as arrays. For example, this code:

```js
var points = [
	[0, 1],
	[4, 5],
	[5, 3],
	[2, 0],
	[0, 1]
];

var path = Smooth(points, {method: Smooth.METHOD_CUBIC, clip:Smooth.CLIP_PERIODIC});
```

could be used to create a path function along which to animate a sprite in a loop.


<a name = "rm-future" />
# Future Plans

* Interpolation of non-uniform arrays (objects with arbitrary numeric indexes)
* More interpolation methods
* Some control over tangent selection with cubic interpolation
* Custom interpolation methods (maybe)