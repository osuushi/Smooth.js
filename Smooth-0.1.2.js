
/*
Smooth.js version 0.1.2

Turn arrays into smooth functions.

Copyright 2012 Spencer Cohen
Licensed under MIT license (see "Smooth.js MIT license.txt")
*/

/*Constants (these are accessible by Smooth.WHATEVER in user space)
*/

(function() {
  var AbstractInterpolator, CubicInterpolator, Enum, LinearInterpolator, NearestInterpolator, Smooth, clipClamp, clipMirror, clipPeriodic, defaultConfig, getColumn, k, root, v,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Enum = {
    /*Interpolation methods
    */
    METHOD_NEAREST: 0,
    METHOD_LINEAR: 1,
    METHOD_CUBIC: 2,
    /*Input clipping modes
    */
    CLIP_CLAMP: 0,
    CLIP_ZERO: 1,
    CLIP_PERIODIC: 2,
    CLIP_MIRROR: 3,
    /* Constants for control over the cubic interpolation tension
    */
    CUBIC_TENSION_DEFAULT: 0,
    CUBIC_TENSION_CATMULL_ROM: 0
  };

  defaultConfig = {
    method: Enum.METHOD_CUBIC,
    cubicTension: Enum.CUBIC_TENSION_DEFAULT,
    clip: Enum.CLIP_CLAMP
  };

  /*Index clipping functions
  */

  clipClamp = function(i, n) {
    return Math.max(0, Math.min(i, n - 1));
  };

  clipPeriodic = function(i, n) {
    i = i % n;
    if (i < 0) i += n;
    return i;
  };

  clipMirror = function(i, n) {
    var period;
    period = 2 * (n - 1);
    i = clipPeriodic(i, period);
    if (i > n - 1) i = period - i;
    return i;
  };

  /*
  Abstract scalar interpolation class which provides common functionality for all interpolators
  
  Subclasses must override interpolate().
  */

  AbstractInterpolator = (function() {

    function AbstractInterpolator(array, config) {
      var err;
      this.array = array.slice(0);
      this.length = this.array.length;
      this.clipHelper = (function() {
        switch (config.clip) {
          case Enum.CLIP_CLAMP:
            return this.clipHelperClamp;
          case Enum.CLIP_ZERO:
            return this.clipHelperZero;
          case Enum.CLIP_PERIODIC:
            return this.clipHelperPeriodic;
          case Enum.CLIP_MIRROR:
            return this.clipHelperMirror;
          default:
            err = new Error;
            err.message = "The clipping mode " + config.clip + " is invalid.";
            throw err;
        }
      }).call(this);
    }

    AbstractInterpolator.prototype.getClippedInput = function(i) {
      if ((0 <= i && i < this.length)) {
        return this.array[i];
      } else {
        return this.clipHelper(i);
      }
    };

    AbstractInterpolator.prototype.clipHelperClamp = function(i) {
      return this.array[clipClamp(i, this.length)];
    };

    AbstractInterpolator.prototype.clipHelperZero = function(i) {
      return 0;
    };

    AbstractInterpolator.prototype.clipHelperPeriodic = function(i) {
      return this.array[clipPeriodic(i, this.length)];
    };

    AbstractInterpolator.prototype.clipHelperMirror = function(i) {
      return this.array[clipMirror(i, this.length)];
    };

    AbstractInterpolator.prototype.interpolate = function(t) {
      var err;
      err = new Error;
      err.message = 'Subclasses of AbstractInterpolator must override the interpolate() method.';
      throw err;
    };

    return AbstractInterpolator;

  })();

  NearestInterpolator = (function(_super) {

    __extends(NearestInterpolator, _super);

    function NearestInterpolator() {
      NearestInterpolator.__super__.constructor.apply(this, arguments);
    }

    NearestInterpolator.prototype.interpolate = function(t) {
      return this.getClippedInput(Math.round(t));
    };

    return NearestInterpolator;

  })(AbstractInterpolator);

  LinearInterpolator = (function(_super) {

    __extends(LinearInterpolator, _super);

    function LinearInterpolator() {
      LinearInterpolator.__super__.constructor.apply(this, arguments);
    }

    LinearInterpolator.prototype.interpolate = function(t) {
      var a, b, k;
      k = Math.floor(t);
      a = this.getClippedInput(k);
      b = this.getClippedInput(k + 1);
      t -= k;
      return (1 - t) * a + t * b;
    };

    return LinearInterpolator;

  })(AbstractInterpolator);

  CubicInterpolator = (function(_super) {

    __extends(CubicInterpolator, _super);

    function CubicInterpolator(array, config) {
      this.tangentFactor = 1 - Math.max(0, Math.min(1, config.cubicTension));
      CubicInterpolator.__super__.constructor.apply(this, arguments);
    }

    CubicInterpolator.prototype.getTangent = function(k) {
      return this.tangentFactor * (this.getClippedInput(k + 1) - this.getClippedInput(k - 1)) / 2;
    };

    CubicInterpolator.prototype.interpolate = function(t) {
      var k, m, p, t2, t3;
      k = Math.floor(t);
      m = [this.getTangent(k), this.getTangent(k + 1)];
      p = [this.getClippedInput(k), this.getClippedInput(k + 1)];
      t -= k;
      t2 = t * t;
      t3 = t * t2;
      return (2 * t3 - 3 * t2 + 1) * p[0] + (t3 - 2 * t2 + t) * m[0] + (-2 * t3 + 3 * t2) * p[1] + (t3 - t2) * m[1];
    };

    return CubicInterpolator;

  })(AbstractInterpolator);

  getColumn = function(arr, i) {
    var row, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      row = arr[_i];
      _results.push(row[i]);
    }
    return _results;
  };

  Smooth = function(arr, config) {
    var dataType, err, i, interpolator, interpolatorClass, interpolators, k, v;
    if (config == null) config = {};
    for (k in defaultConfig) {
      if (!__hasProp.call(defaultConfig, k)) continue;
      v = defaultConfig[k];
      if (config[k] == null) config[k] = v;
    }
    interpolatorClass = (function() {
      switch (config.method) {
        case Enum.METHOD_NEAREST:
          return NearestInterpolator;
        case Enum.METHOD_LINEAR:
          return LinearInterpolator;
        case Enum.METHOD_CUBIC:
          return CubicInterpolator;
        default:
          err = new Error;
          err.message = "The interpolation method " + config.method + " is invalid.";
          throw err;
      }
    })();
    if (!arr.length) {
      err = new Error;
      err.message = 'Array must have at least one element.';
      throw err;
    }
    dataType = Object.prototype.toString.call(arr[0]);
    switch (dataType) {
      case '[object Number]':
        interpolator = new interpolatorClass(arr, config);
        return function(t) {
          return interpolator.interpolate(t);
        };
      case '[object Array]':
        interpolators = (function() {
          var _ref, _results;
          _results = [];
          for (i = 0, _ref = arr[0].length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
            _results.push(new interpolatorClass(getColumn(arr, i), config));
          }
          return _results;
        })();
        return function(t) {
          var interpolator, _i, _len, _results;
          _results = [];
          for (_i = 0, _len = interpolators.length; _i < _len; _i++) {
            interpolator = interpolators[_i];
            _results.push(interpolator.interpolate(t));
          }
          return _results;
        };
      default:
        err = new Error;
        err.message = 'Invalid element type: #{dataType}';
        throw err;
    }
  };

  for (k in Enum) {
    if (!__hasProp.call(Enum, k)) continue;
    v = Enum[k];
    Smooth[k] = v;
  }

  root = typeof exports !== "undefined" && exports !== null ? exports : window;

  root.Smooth = Smooth;

}).call(this);
