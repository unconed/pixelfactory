(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ASPECT, HEIGHT, WIDTH, deepred, enlarge, enter, formatNumber, getOverlays, line1, line2, line3, line4, mathbox, pixelCanvas, pixelCanvasRGBA, pixelCanvasText, pixelCanvasTextA, pixelCanvasTextB, pixelCanvasTextG, pixelCanvasTextR, pixelGrid, pixelRTT, pixelRTTRGBA, pixelSlide, pixelView, present, ref, three, triangle, triangleFace, triangleSnap, triangleSnapFace, triangleSnapOutline;

window.mathbox = (ref = mathBox({
  plugins: ['core', 'cursor'],
  time: {
    delay: 10
  },
  mathbox: {
    warmup: 2
  },
  splash: {
    color: 'blue'
  },
  controls: {
    klass: THREE.OrbitControls,
    parameters: {
      noKeys: true
    }
  }
}), mathbox = ref.mathbox, three = ref.three, ref);

window.three = three;

MathBox.DOM.Types.latex = MathBox.DOM.createClass({
  render: function(el, props, children) {
    props.innerHTML = katex.renderToString(children);
    return el('span', props);
  }
});

mathbox = mathbox.v2();

three.renderer.setClearColor(new THREE.Color(0xFFFFFF), 1.0);

deepred = 0xa00000;

triangle = function(emit, i, t) {
  var theta, x, y;
  theta = i * τ / 3 + t / 4;
  x = Math.sin(theta) * .8;
  y = Math.cos(theta) * .8;
  return emit(x * 10 + 16, y * 10 + 10);
};

triangleSnap = function(emit, i, t) {
  var _emit;
  _emit = function(x, y) {
    x = Math.round(x - .5) + .5;
    y = Math.round(y - .5) + .5;
    return emit(x, y);
  };
  return triangle(_emit, i, t);
};

formatNumber = MathBox.Util.Pretty.number();

WIDTH = 32;

HEIGHT = 20;

ASPECT = WIDTH / HEIGHT;

mathbox.set({
  focus: 4
});

present = mathbox.present({
  index: 0
});

present.slide();

pixelSlide = present.slide();

pixelView = pixelSlide.camera({
  proxy: true,
  position: [0, 0, 4.5],
  fov: 30
}).step({
  trigger: 6,
  duration: 2,
  stops: [0, 1, 1.5, 2.5, 4.5],
  script: {
    0: [
      {
        position: [0, 0, 4.5],
        rotation: [0, 0, 0]
      }
    ],
    1: [
      {
        position: [0, .2, 2]
      }
    ],
    1.5: [
      {
        position: [0, .2, .75]
      }
    ],
    2.5: [
      {
        position: [0, -1.2, .75],
        rotation: [1, 0, .3]
      }
    ],
    4.5: [
      {
        position: [0, 0, 4.5],
        rotation: [0, 0, 0]
      }
    ]
  }
}).cartesian({
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
});

pixelView.slide({
  late: Infinity
}).reveal({
  stagger: [5],
  duration: .5
}).axis({
  axis: 1,
  width: 5,
  color: 0,
  zBias: 20,
  color: 0x3080FF
}).axis({
  axis: 2,
  width: 5,
  color: 0,
  crossed: true,
  zBias: 20,
  color: 0x40A020
});

pixelRTT = pixelView.rtt({
  width: WIDTH,
  height: HEIGHT,
  minFilter: 'nearest',
  magFilter: 'nearest'
});

pixelRTTRGBA = pixelRTT.shader({
  code: "uniform float split;\nvec4 getSample(vec4 xyzw);\nvec4 splitChannelsRGBA(vec4 xyzw) {\n  \n  vec4 rgba = getSample(xyzw);\n  vec2 xy = fract(xyzw.xy + .5);\n\n  const float alpha = 1.0;\n  vec2 uv = xy - .5;\n  if (dot(uv, uv) < split) {\n    return vec4(rgba.xyz, alpha);\n  }\n\n  if (xy.x < .5) {\n    if (xy.y < .5) {\n      return vec4(0.0, 0.0, rgba.b, alpha);\n    }\n    else {\n      return vec4(rgba.r, 0.0, 0.0, alpha);\n    }  \n  }\n  else {\n    if (xy.y < .5) {\n      return vec4(vec3(1.0 - rgba.a), alpha);\n    }\n    else {\n      return vec4(0.0, rgba.g, 0.0, alpha);\n    }  \n  }\n}"
}).step({
  trigger: 7,
  duration: 2,
  stops: [-1, 1, 1, 2],
  script: [
    [
      {
        split: 0
      }
    ], [
      {
        split: .04
      }
    ], [
      {
        split: 0
      }
    ]
  ]
}).resample();

pixelRTT.camera({
  position: [0, 0, 1],
  fov: 90
});

pixelGrid = pixelRTT.cartesian({
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
});

pixelCanvas = pixelView.reveal({
  stagger: [5],
  duration: 1
}).grid({
  divideX: WIDTH,
  divideY: HEIGHT,
  width: 2,
  crossed: true,
  zBias: 15,
  color: 0
}).step({
  trigger: 6,
  duration: 2,
  stops: [0, 1, 1, 1, 2],
  script: [
    [
      {
        width: 2,
        opacity: .5
      }
    ], [
      {
        width: 4,
        opacity: 1
      }
    ], [
      {
        width: 2,
        opacity: .5
      }
    ]
  ]
}).area({
  width: 2,
  height: 2
}).surface({
  color: 0xFFFFFF,
  map: pixelRTT
}).end();

line1 = pixelGrid.slide({
  late: 7
}).view({
  range: [[8, 25], [10, 11]]
}).area({
  width: 2,
  height: 2
}).grow({
  width: 'first'
}).step({
  trigger: 0,
  duration: .5,
  script: [
    [
      {
        scale: 0
      }
    ], [
      {
        scale: 1
      }
    ]
  ]
}).surface({
  color: 0x2090FF
}).step({
  trigger: 6,
  delay: 2.5,
  duration: 3,
  stops: [0, 1],
  script: [
    [
      {
        opacity: 1
      }
    ], [
      {}, {
        opacity: function(t) {
          return .5 - .5 * Math.cos(t * .78);
        }
      }
    ]
  ]
});

line2 = pixelGrid.slide({
  late: 6
}).view({
  range: [[15, 17], [4, 20]]
}).area({
  width: 2,
  height: 2
}).grow({
  height: 'first'
}).step({
  trigger: 0,
  duration: .5,
  script: [
    [
      {
        scale: 0
      }
    ], [
      {
        scale: 1
      }
    ]
  ]
}).surface({
  color: 0xC02070
}).step({
  trigger: 5,
  delay: 2.5,
  duration: 3,
  stops: [0, 1],
  script: [
    [
      {
        opacity: 1
      }
    ], [
      {}, {
        opacity: function(t) {
          return .5 - .5 * Math.cos(t * .65);
        }
      }
    ]
  ]
});

line3 = pixelGrid.slide({
  late: 5
}).transform({
  rotation: [0, 0, 1.2],
  position: [19.5, 10]
}).view({
  range: [[0, 1], [0, 9.9]]
}).area({
  width: 2,
  height: 2
}).grow({
  height: 'first'
}).step({
  trigger: 0,
  duration: .5,
  script: [
    [
      {
        scale: 0
      }
    ], [
      {
        scale: 1
      }
    ]
  ]
}).surface({
  color: 0x8040B0
}).step({
  trigger: 4,
  delay: 2.5,
  duration: 3,
  stops: [0, 1],
  script: [
    [
      {
        opacity: 1
      }
    ], [
      {}, {
        opacity: function(t) {
          return .5 - .5 * Math.cos(t * .81);
        }
      }
    ]
  ]
});

line4 = pixelGrid.slide({
  late: 4
}).reveal({
  duration: .5,
  stagger: [0, 10000]
}).view({
  range: [[7, 25], [18, 5]]
}).area({
  width: 2,
  height: 2
}).matrix({
  width: 2,
  height: 2,
  expr: function(emit, i, j) {
    var c;
    c = j;
    return emit(0, .25, .5, c);
  }
}).surface({
  points: '<<',
  colors: '<',
  color: 0xffffff
}).step({
  trigger: 3,
  delay: 2.5,
  duration: 3,
  stops: [0, 1],
  script: [
    [
      {
        opacity: 1
      }
    ], [
      {}, {
        opacity: function(t) {
          return .5 - .5 * Math.cos(t);
        }
      }
    ]
  ]
});

pixelCanvasRGBA = pixelView.slide({
  late: 3
}).reveal({
  stagger: [5],
  delayEnter: 1,
  duration: 1
}).area({
  width: 2,
  height: 2
}).surface({
  color: 0xFFFFFF,
  map: pixelRTTRGBA,
  zBias: 5,
  zOrder: -100
});

pixelCanvasText = pixelView.slide({
  late: 1
}).reveal({
  stagger: [2],
  delayEnter: 1,
  duration: 1
});

pixelCanvasTextR = pixelCanvasText.area({
  width: WIDTH,
  height: HEIGHT,
  centeredX: true,
  centeredY: true
}).text({
  width: 256,
  weight: 'bold',
  expr: function(emit, i) {
    return emit(i);
  }
}).shader({
  sources: pixelRTT,
  code: "vec4 getColorSample(vec4 xyzw);\nvec4 getTextSample(vec4 xyzw);\n\nvec4 resample(vec4 xyzw) {          \n  vec4 rgba = getColorSample(xyzw);\n  float i   = floor(rgba.r * 255.0 + .5);\n  return getTextSample(vec4(i, 0, 0, 0));\n}"
}).retext({
  sample: 'absolute',
  width: WIDTH,
  height: HEIGHT
}).transform({
  position: [-.24, .24]
}).label({
  offset: [0, 0],
  background: 0,
  color: 0xFF8080,
  zIndex: 1,
  zBias: 5,
  zOrder: -100,
  size: 8,
  outline: 1,
  depth: .8
});

pixelCanvasTextG = pixelCanvasText.area({
  width: WIDTH,
  height: HEIGHT,
  centeredX: true,
  centeredY: true
}).text({
  width: 256,
  weight: 'bold',
  expr: function(emit, i) {
    return emit(i);
  }
}).shader({
  sources: pixelRTT,
  code: "vec4 getColorSample(vec4 xyzw);\nvec4 getTextSample(vec4 xyzw);\n\nvec4 resample(vec4 xyzw) {          \n  vec4 rgba = getColorSample(xyzw);\n  float i   = floor(rgba.g * 255.0 + .5);\n  return getTextSample(vec4(i, 0, 0, 0));\n}"
}).retext({
  sample: 'absolute',
  width: WIDTH,
  height: HEIGHT
}).transform({
  position: [.24, .24]
}).label({
  offset: [0, 0],
  background: 0,
  color: 0x80FF80,
  zIndex: 1,
  zBias: 5,
  zOrder: -100,
  size: 8,
  outline: 1,
  depth: .8
});

pixelCanvasTextB = pixelCanvasText.area({
  width: WIDTH,
  height: HEIGHT,
  centeredX: true,
  centeredY: true
}).text({
  width: 256,
  weight: 'bold',
  expr: function(emit, i) {
    return emit(i);
  }
}).shader({
  sources: pixelRTT,
  code: "vec4 getColorSample(vec4 xyzw);\nvec4 getTextSample(vec4 xyzw);\n\nvec4 resample(vec4 xyzw) {          \n  vec4 rgba = getColorSample(xyzw);\n  float i   = floor(rgba.b * 255.0 + .5);\n  return getTextSample(vec4(i, 0, 0, 0));\n}"
}).retext({
  sample: 'absolute',
  width: WIDTH,
  height: HEIGHT
}).transform({
  position: [-.24, -.24]
}).label({
  offset: [0, 0],
  background: 0,
  color: 0xA0A0FF,
  zIndex: 1,
  zBias: 5,
  zOrder: -100,
  size: 8,
  outline: 1,
  depth: .8
});

pixelCanvasTextA = pixelCanvasText.area({
  width: WIDTH,
  height: HEIGHT,
  centeredX: true,
  centeredY: true
}).text({
  width: 256,
  weight: 'bold',
  expr: function(emit, i) {
    return emit(i);
  }
}).shader({
  sources: pixelRTT,
  code: "vec4 getColorSample(vec4 xyzw);\nvec4 getTextSample(vec4 xyzw);\n\nvec4 resample(vec4 xyzw) {          \n  vec4 rgba = getColorSample(xyzw);\n  float i   = floor(rgba.a * 255.0 + .5);\n  return getTextSample(vec4(i, 0, 0, 0));\n}"
}).retext({
  sample: 'absolute',
  width: WIDTH,
  height: HEIGHT
}).transform({
  position: [.24, -.24]
}).label({
  offset: [0, 0],
  background: 0,
  color: 0x808080,
  zIndex: 1,
  zBias: 5,
  zOrder: -100,
  size: 8,
  outline: 1,
  depth: .8
});

triangleSnapFace = pixelGrid.slide({
  steps: 0,
  from: 10,
  to: 12
}).reveal({
  duration: 1
}).array({
  channels: 2,
  length: 3,
  expr: triangleSnap
}).transpose({
  order: 'yzwx'
}).face({
  color: 0,
  opacity: .5
});

triangleSnapOutline = pixelView.slide({
  steps: 0,
  from: 11,
  to: 12
}).reveal({
  duration: 1
}).array({
  channels: 2,
  length: 4,
  expr: triangleSnap
}).line({
  color: deepred,
  width: 10
}).slice({
  width: [0, 3]
}).point({
  color: deepred,
  size: 30
});

triangleFace = pixelGrid.slide({
  steps: 0,
  from: 12,
  to: 14
}).reveal({
  duration: 1
}).array({
  channels: 2,
  length: 3,
  expr: triangle
}).transpose({
  order: 'yzwx'
}).face({
  color: 0,
  opacity: .5
});

triangleSnap = pixelView.slide({
  steps: 0,
  from: 12,
  to: 14
}).reveal({
  duration: 1
}).array({
  channels: 2,
  length: 4,
  expr: triangle
}).line({
  color: deepred,
  width: 10
}).slice({
  width: [0, 3]
}).point({
  color: deepred,
  size: 30
});

window.onmessage = function(e) {
  var data;
  data = e.data;
  if (data.type === 'slideshow') {
    return present.set('index', data.i + 1);
  }
};

enlarge = function(el, zoom) {
  var k, len, ref1, results, svg;
  el.style.zoom = zoom;
  ref1 = el.querySelectorAll('.shadergraph-graph');
  results = [];
  for (k = 0, len = ref1.length; k < len; k++) {
    el = ref1[k];
    if (typeof el.update === "function") {
      el.update();
    }
    results.push((function() {
      var l, len1, ref2, results1;
      ref2 = el.querySelectorAll('svg');
      results1 = [];
      for (l = 0, len1 = ref2.length; l < len1; l++) {
        svg = ref2[l];
        results1.push(svg.setAttribute('height', svg.getAttribute('height') * zoom));
      }
      return results1;
    })());
  }
  return results;
};

enter = function(el) {
  return setTimeout(function() {
    el.classList.add('slide-delay-2');
    return el.classList.add('slide-active');
  });
};

three.on('mathbox/progress', function(e) {
  var i, j, k, ref1, results;
  i = present[0].get('index');
  if (e.total === e.current && i <= 2) {
    results = [];
    for (j = k = ref1 = i; ref1 <= 2 ? k < 2 : k > 2; j = ref1 <= 2 ? ++k : --k) {
      results.push(window.parent.postMessage({
        type: 'slideshow',
        method: 'next'
      }, '*'));
    }
    return results;
  }
});

getOverlays = function() {
  return document.querySelectorAll('.shadergraph-overlay');
};

present.on('change', function(e) {
  var step;
  return step = present[0].get('index');

  /*
  if step == 19 or step == 21
    el.remove() for el in getOverlays()
  if step == 20
    surface = mathbox.select('vector')[0]
    surface?.controller.objects[0].renders[0].material.fragmentGraph.inspect()
    for el in getOverlays()
      enlarge el, 2
      enter   el
   */
});

if (window === top) {
  window.onkeydown = function(e) {
    switch (e.keyCode) {
      case 37:
      case 38:
        return present[0].set('index', present[0].get('index') - 1);
      case 39:
      case 40:
        return present[0].set('index', present[0].get('index') + 1);
    }
  };
}



},{}]},{},[1]);
