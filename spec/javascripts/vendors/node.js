(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
!function(a,b){"use strict";!function(a){a.utils={},a.utils.merge=function(a,b,c){if("object"!=typeof a)throw Error("Target must be object");for(var d in b)b.hasOwnProperty(d)&&(a[d]&&c||(a[d]=b[d]))}}(b="undefined"==typeof b?{}:b),function(a){function b(){}var c={},d={};a.datum=new b,b.prototype.checkDefined=function(a){if(c[a])return!0;throw Error(a+" is not defined")},b.prototype.setDefined=function(a,b,d){this.setAlias(b,d),c[a]={factories:[],options:b,defined:d}},b.prototype.setAlias=function(a,b){var c=a.alias||[];if(delete a.alias,c instanceof Array)for(var d=c.length-1;d>=0;d--)this.setDefined(c[d],a,b);else this.setDefined(c,a,b)},b.prototype.getOptions=function(a){return this.checkDefined(a),c[a].options},b.prototype.getDefined=function(a){return this.checkDefined(a),c[a].defined},b.prototype.createFactory=function(b,d){var e=new a.Model(b,d);return c[b].factories.push(e),e},b.prototype.remove=function(a){return this.checkDefined(a),delete c[a],this},b.prototype.clear=function(){for(var a in c)c.hasOwnProperty(a)&&this.remove(a);return this},b.prototype.count=function(){return Object.keys(c).length},b.prototype.setSequence=function(a,b){d[a]={constructor:b,next_id:0}},b.prototype.nextSequence=function(a){return d[a].next_id+=1,d[a].constructor(d[a].next_id)}}(b="undefined"==typeof b?{}:b),function(a){function b(a,c){return this instanceof b?(this.__name__=a,void d(this,c)):new b(a)}function c(a,c,d,e,f){var g;return e||(e=d,d=c),e=e||(f?d:a.getName())+"_id",g=new b(d),a[c]=g,g[a.getName()]=a,f?a[e]=g.id:g[e]=a.id,g}function d(b,c){var d=b.getName(),f=a.datum.getOptions(d),g=a.datum.getDefined(d);g.call(b),a.utils.merge(b,c),e(b,f.inherit)}function e(c,d){if(d){var e=a.datum.getDefined(d),f=new b(d);e.call(f),a.utils.merge(c,f,!0);for(var g,h,i=Object.keys(c),j=i.length-1;j>=0;j--)g=i[j],h=c[g],h instanceof Array?h.forEach(function(a){a instanceof b&&a[f.getName()+"_id"]&&(delete a[f.getName()+"_id"],a[c.getName()+"_id"]=c.id)}):h instanceof b&&h[f.getName()+"_id"]&&(delete h[f.getName()+"_id"],h[c.getName()+"_id"]=c.id)}}a.Model=b,b.prototype.getName=function(){return this.__name__},b.prototype.attributes=function(){return this.toJSON(!0)},b.prototype.toJSON=function(a,c){var d=Object.keys(this),e={};"undefined"!=typeof c&&c instanceof Array||(c=[]),c.push(this.getName());for(var f,g,h=d.length-1;h>=0;h--)g=d[h],f=this[g],f instanceof Array?f.forEach(function(d){if(d instanceof b){if(a||-1!==c.indexOf(d.getName()))return;d=d.toJSON(c)}e[g]=e[g]||[],e[g].push(d)}):f instanceof b?a||-1!==c.indexOf(f.getName())||(e[g]=f.toJSON(c)):/^__(.)+__$/.test(g)||(e[g]=f);return e},b.prototype.belongTo=function(a,b,d){return c(this,a,b,d,!0)},b.prototype.hasOne=function(a,b,d){return c(this,a,b,d,!1)},b.prototype.hasMany=function(a,c,d,e){"number"==typeof c&&(e=d,d=c,c=null),c=c||a,e=e||this.getName()+"_id";for(var f,g=[],h=d-1;h>=0;h--)f=new b(c),f[e]=this.id,g.push(f);this[a]=g},b.prototype.sequence=function(b,c){this[c]=a.datum.nextSequence(b)}}(b="undefined"==typeof b?{}:b),function(a,b){b.version={full:"0.2.0",major:0,minor:2,dot:0,codeName:"sapphire"},b.define=function(a){var c=arguments[arguments.length-1],d=3===arguments.length?arguments[1]:{};if("function"!=typeof c)throw Error("argument must be a function");b.datum.setDefined(a,d,c)},b.defined=function(a){try{b.datum.checkDefined(a)}catch(c){return!1}return!0},b.create=function(a,c){return b.datum.createFactory(a,c)},b.createLists=function(a,c){for(var d=[];c--;)d.push(b.datum.createFactory(a));return d},b.attributesFor=function(a){var c=new b.Model(a);return c.attributes()},b.clear=function(a){a?b.datum.remove(a):b.datum.clear()},b.sequence=function(a,c){if("function"!=typeof c)throw Error("argument must be a function");b.datum.setSequence(a,c)},b.findDefinitions=function(){if(!(a.definitionFilePaths instanceof Array))throw Error("FactoryGirl.definitionFilePaths must be an array");if("undefined"==typeof require)throw Error("FactoryGirl.findDefinitions is not available on browser");var b=require("fs"),c=require("path");a.definitionFilePaths.forEach(function(a){b.readdirSync(a).forEach(function(b){require(c.join(a,b))})})},a.version=b.version,a.define=b.define,a.defined=b.defined,a.create=b.create,a.createLists=b.createLists,a.attributesFor=b.attributesFor,a.clear=b.clear,a.sequence=b.sequence,a.findDefinitions=b.findDefinitions}(a="undefined"==typeof a?{}:a,b="undefined"==typeof b?{}:b)}(FactoryGirl="undefined"==typeof module?{}:module.exports,{},this);
},{"fs":4,"path":5}],2:[function(require,module,exports){
module.exports = require('./build/factory_girl.min.js')

},{"./build/factory_girl.min.js":1}],3:[function(require,module,exports){
window.FactoryGirl = require('factory_girl');

},{"factory_girl":2}],4:[function(require,module,exports){

},{}],5:[function(require,module,exports){
(function (process){
// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

// resolves . and .. elements in a path array with directory names there
// must be no slashes, empty elements, or device names (c:\) in the array
// (so also no leading and trailing slashes - it does not distinguish
// relative and absolute paths)
function normalizeArray(parts, allowAboveRoot) {
  // if the path tries to go above the root, `up` ends up > 0
  var up = 0;
  for (var i = parts.length - 1; i >= 0; i--) {
    var last = parts[i];
    if (last === '.') {
      parts.splice(i, 1);
    } else if (last === '..') {
      parts.splice(i, 1);
      up++;
    } else if (up) {
      parts.splice(i, 1);
      up--;
    }
  }

  // if the path is allowed to go above the root, restore leading ..s
  if (allowAboveRoot) {
    for (; up--; up) {
      parts.unshift('..');
    }
  }

  return parts;
}

// Split a filename into [root, dir, basename, ext], unix version
// 'root' is just a slash, or nothing.
var splitPathRe =
    /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
var splitPath = function(filename) {
  return splitPathRe.exec(filename).slice(1);
};

// path.resolve([from ...], to)
// posix version
exports.resolve = function() {
  var resolvedPath = '',
      resolvedAbsolute = false;

  for (var i = arguments.length - 1; i >= -1 && !resolvedAbsolute; i--) {
    var path = (i >= 0) ? arguments[i] : process.cwd();

    // Skip empty and invalid entries
    if (typeof path !== 'string') {
      throw new TypeError('Arguments to path.resolve must be strings');
    } else if (!path) {
      continue;
    }

    resolvedPath = path + '/' + resolvedPath;
    resolvedAbsolute = path.charAt(0) === '/';
  }

  // At this point the path should be resolved to a full absolute path, but
  // handle relative paths to be safe (might happen when process.cwd() fails)

  // Normalize the path
  resolvedPath = normalizeArray(filter(resolvedPath.split('/'), function(p) {
    return !!p;
  }), !resolvedAbsolute).join('/');

  return ((resolvedAbsolute ? '/' : '') + resolvedPath) || '.';
};

// path.normalize(path)
// posix version
exports.normalize = function(path) {
  var isAbsolute = exports.isAbsolute(path),
      trailingSlash = substr(path, -1) === '/';

  // Normalize the path
  path = normalizeArray(filter(path.split('/'), function(p) {
    return !!p;
  }), !isAbsolute).join('/');

  if (!path && !isAbsolute) {
    path = '.';
  }
  if (path && trailingSlash) {
    path += '/';
  }

  return (isAbsolute ? '/' : '') + path;
};

// posix version
exports.isAbsolute = function(path) {
  return path.charAt(0) === '/';
};

// posix version
exports.join = function() {
  var paths = Array.prototype.slice.call(arguments, 0);
  return exports.normalize(filter(paths, function(p, index) {
    if (typeof p !== 'string') {
      throw new TypeError('Arguments to path.join must be strings');
    }
    return p;
  }).join('/'));
};


// path.relative(from, to)
// posix version
exports.relative = function(from, to) {
  from = exports.resolve(from).substr(1);
  to = exports.resolve(to).substr(1);

  function trim(arr) {
    var start = 0;
    for (; start < arr.length; start++) {
      if (arr[start] !== '') break;
    }

    var end = arr.length - 1;
    for (; end >= 0; end--) {
      if (arr[end] !== '') break;
    }

    if (start > end) return [];
    return arr.slice(start, end - start + 1);
  }

  var fromParts = trim(from.split('/'));
  var toParts = trim(to.split('/'));

  var length = Math.min(fromParts.length, toParts.length);
  var samePartsLength = length;
  for (var i = 0; i < length; i++) {
    if (fromParts[i] !== toParts[i]) {
      samePartsLength = i;
      break;
    }
  }

  var outputParts = [];
  for (var i = samePartsLength; i < fromParts.length; i++) {
    outputParts.push('..');
  }

  outputParts = outputParts.concat(toParts.slice(samePartsLength));

  return outputParts.join('/');
};

exports.sep = '/';
exports.delimiter = ':';

exports.dirname = function(path) {
  var result = splitPath(path),
      root = result[0],
      dir = result[1];

  if (!root && !dir) {
    // No dirname whatsoever
    return '.';
  }

  if (dir) {
    // It has a dirname, strip trailing slash
    dir = dir.substr(0, dir.length - 1);
  }

  return root + dir;
};


exports.basename = function(path, ext) {
  var f = splitPath(path)[2];
  // TODO: make this comparison case-insensitive on windows?
  if (ext && f.substr(-1 * ext.length) === ext) {
    f = f.substr(0, f.length - ext.length);
  }
  return f;
};


exports.extname = function(path) {
  return splitPath(path)[3];
};

function filter (xs, f) {
    if (xs.filter) return xs.filter(f);
    var res = [];
    for (var i = 0; i < xs.length; i++) {
        if (f(xs[i], i, xs)) res.push(xs[i]);
    }
    return res;
}

// String.prototype.substr - negative index don't work in IE8
var substr = 'ab'.substr(-1) === 'b'
    ? function (str, start, len) { return str.substr(start, len) }
    : function (str, start, len) {
        if (start < 0) start = str.length + start;
        return str.substr(start, len);
    }
;

}).call(this,require('_process'))
},{"_process":6}],6:[function(require,module,exports){
// shim for using process in browser

var process = module.exports = {};

process.nextTick = (function () {
    var canSetImmediate = typeof window !== 'undefined'
    && window.setImmediate;
    var canMutationObserver = typeof window !== 'undefined'
    && window.MutationObserver;
    var canPost = typeof window !== 'undefined'
    && window.postMessage && window.addEventListener
    ;

    if (canSetImmediate) {
        return function (f) { return window.setImmediate(f) };
    }

    var queue = [];

    if (canMutationObserver) {
        var hiddenDiv = document.createElement("div");
        var observer = new MutationObserver(function () {
            var queueList = queue.slice();
            queue.length = 0;
            queueList.forEach(function (fn) {
                fn();
            });
        });

        observer.observe(hiddenDiv, { attributes: true });

        return function nextTick(fn) {
            if (!queue.length) {
                hiddenDiv.setAttribute('yes', 'no');
            }
            queue.push(fn);
        };
    }

    if (canPost) {
        window.addEventListener('message', function (ev) {
            var source = ev.source;
            if ((source === window || source === null) && ev.data === 'process-tick') {
                ev.stopPropagation();
                if (queue.length > 0) {
                    var fn = queue.shift();
                    fn();
                }
            }
        }, true);

        return function nextTick(fn) {
            queue.push(fn);
            window.postMessage('process-tick', '*');
        };
    }

    return function nextTick(fn) {
        setTimeout(fn, 0);
    };
})();

process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

// TODO(shtylman)
process.cwd = function () { return '/' };
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};

},{}]},{},[3]);
