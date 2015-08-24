(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var camera, emitCurve, emitSurface, enlarge, enter, formatNumber, intensitySteps, mathbox, orbit, polar, present, ref, slide, subslide, three, time, view;

window.mathbox = (ref = mathBox({
  plugins: ['core']
}), mathbox = ref.mathbox, three = ref.three, ref);

mathbox = mathbox.v2();

three.renderer.setClearColor(new THREE.Color(0xFFFFFF), 1.0);

formatNumber = MathBox.Util.Pretty.number();

emitCurve = function(emit, x, i, t) {
  return emit(x, π / 2 + .6 * Math.sin(x + t) + .3 * Math.sin(x * 2 + t * 1.81) + .1825 * Math.sin(x * 3 + t * 2.18));
};

emitSurface = function(emit, x, y, i, j, t) {
  return emit(x, π / 2 + .6 * Math.sin(x + t - y + 2 * Math.sin(y)) + .3 * Math.sin(x * 2 + y * 2 + t * 1.81) + .1825 * Math.sin(x * 3 - y * 2 + t * 2.18), y);
};

orbit = function(t) {
  return [Math.cos(t / 1) * .5 - 2, 0, 1 + .25 * Math.sin(t / 1)];
};

time = function(t) {
  return t / 4;
};

intensitySteps = {
  stops: [0, 0, 1, 3, 4, 5, 6, 7],
  duration: 0,
  pace: 5,
  script: {
    "0": [
      {
        intensity: 0
      }
    ],
    "0.5": [
      {
        intensity: 0
      }
    ],
    "1": [
      {
        intensity: 2.5
      }
    ],
    "1.5": [
      {
        intensity: 0
      }
    ],
    "3": [
      {
        intensity: 3
      }
    ],
    "4": [
      {
        intensity: 0
      }
    ],
    "5": [
      {}, {
        intensity: function(t) {
          return Math.cos(t) * .55;
        }
      }
    ],
    "6": [
      {}, {
        intensity: function(t) {
          return Math.cos(t) * .75;
        }
      }
    ]
  }
};

mathbox.set({
  scale: 500,
  focus: 3
});

present = mathbox.present({
  index: 0 + 7
});

slide = present.slide({
  id: 'top'
});

camera = slide.camera().steps({
  duration: 0,
  pace: 5,
  stops: [0, 0, 2, 4, 5, 5, 6, 7],
  script: [
    {
      key: 0,
      props: {
        position: [0, 0, 3],
        lookAt: [0, 0, 0]
      }
    }, {
      key: 1,
      props: {
        lookAt: [1, 0, -1]
      },
      expr: {
        position: orbit
      }
    }, {
      key: 2,
      props: {
        lookAt: [1, 0, -1]
      },
      expr: {
        position: orbit
      }
    }, {
      key: 4,
      props: {
        position: [-1, 0, 1],
        lookAt: [4, 0, -1]
      }
    }, {
      key: 5,
      props: {
        position: [-1.2, .9, 2.5],
        lookAt: [0, -.7, -1]
      }
    }, {
      key: 6,
      props: {
        position: [-2.4, 1, 1.2],
        lookAt: [0, -.9, -1]
      }
    }, {
      key: 6.2,
      props: {
        position: [-2.1, .6, 1.1],
        lookAt: [0, -.9, -1]
      }
    }
  ]
}).steps({
  target: 'root',
  duration: 0,
  pace: 1,
  trigger: 7,
  stops: [0, 1, 2, 3],
  realTime: true,
  script: [
    [
      {
        speed: 1
      }
    ], [
      {
        speed: .5
      }
    ], [
      {
        speed: .1
      }
    ], [
      {
        speed: 1
      }
    ]
  ]
});

slide.shader({
  code: "uniform float time;\nuniform float intensity;\n\nvec4 warpVertex(vec4 xyzw, inout vec4 stpq) {\n  xyzw *= vec4(1.0, 0.5, 0.5, 0.0);\n\n  xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));\n  xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));\n  xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));\n  xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));\n    \n  xyzw *= vec4(1.0, 2.0, 2.0, 0.0);\n    \n  return xyzw;\n}"
}, {
  time: time
}).steps(intensitySteps);

polar = slide.transition({
  stagger: [10, 0, 0, 0],
  duration: 2
}).polar({
  bend: .25,
  range: [[-π, π], [0, π], [-π / 2, π / 2]],
  scale: [2, 1, 1]
});

polar.steps({
  stops: [0, 11, 11, 11, 12],
  duration: 0,
  pace: 1,
  script: {
    0: [
      {
        bend: 0
      }
    ],
    5: [
      {
        bend: 1
      }
    ],
    7: [
      {
        bend: 1,
        quaternion: [0, 1, 0, 0]
      }
    ],
    11: [
      {
        bend: .33,
        quaternion: [0, 0, 0, -1]
      }
    ],
    12: [
      {
        bend: 0
      }
    ]
  }
});

view = polar.vertex({
  pass: 'data'
}).slide().end().slide().end().slide().end();

subslide = view.slide({
  id: 'grids',
  stay: 3
});

subslide.transition({
  stagger: [10],
  duration: 2
}).transform({
  pass: 'data',
  position: [0, π, 0]
}).grid({
  opacity: .5,
  axes: [1, 3],
  unitX: π,
  unitY: π,
  baseX: 2,
  divideX: 40,
  divideY: 10,
  detailX: 512,
  detailY: 128
}).end().grid({
  opacity: .5,
  axes: [1, 3],
  unitX: π,
  unitY: π,
  baseX: 2,
  divideX: 40,
  divideY: 10,
  detailX: 512,
  detailY: 128
});

view.slide().end();

view.slide().end();

view.slide().end();

view.slide().end();

view.slide().end();

view.transition({
  stagger: [-100]
}).steps({
  trigger: 6,
  pace: 1,
  stops: [0, 1],
  script: {
    0: [
      {
        enter: 0.1,
        exit: 0.1
      }
    ],
    1: [
      {
        enter: 1,
        exit: 1
      }
    ]
  }
}).area({
  id: 'surfaceArea',
  axes: [1, 3],
  width: 193,
  height: 97,
  channels: 3,
  map: emitSurface
}).surface({
  lineX: false,
  lineY: false,
  zBias: 3
}).steps({
  trigger: 8,
  pace: 1,
  stops: [0, 1],
  script: {
    0: [
      {
        color: '#3090FF',
        opacity: 1
      }
    ],
    1: [
      {
        color: '#18487F',
        opacity: .9
      }
    ]
  }
}).surface({
  lineX: true,
  lineY: true,
  solid: false,
  width: 0,
  zBias: 3
}).steps({
  trigger: 8,
  pace: 1,
  stops: [0, 1],
  script: {
    0: [
      {
        color: '#3090FF',
        width: 0
      }
    ],
    1: [
      {
        color: '#18487F',
        width: 1
      }
    ]
  }
});

polar.transition({
  stagger: [-5]
}).steps({
  trigger: 7,
  pace: 1,
  stops: [0, 1],
  script: {
    0: [
      {
        enter: 0.1,
        exit: 0.1
      }
    ],
    1: [
      {
        enter: 1,
        exit: 1
      }
    ]
  }
}).shader({
  id: 'normals',
  code: "uniform float time;\nuniform float intensity;\n\nvec4 warpVertex(vec4 xyzw) {\n  xyzw *= vec4(1.0, 0.5, 0.5, 0.0);\n\n  xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));\n  xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));\n  xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));\n  xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));\n\n  xyzw *= vec4(1.0, 2.0, 2.0, 0.0);\n    \n  return xyzw;\n}\n\nvec4 getSample(vec4 xyzw);\nvec4 getVectorSample(vec4 xyzw) {\n  vec4 xyz0 = vec4(xyzw.xyz, 0.0);\n  vec3 c = warpVertex(getSample(xyz0)).xyz;\n  vec3 r = warpVertex(getSample(xyz0 + vec4(1.0, 0.0, 0.0, 0.0))).xyz;\n  vec3 u = warpVertex(getSample(xyz0 + vec4(0.0, 1.0, 0.0, 0.0))).xyz;\n  vec3 n = normalize(cross(r - c, u - c));\n  return vec4(c - n * xyzw.w * .2, 0.0);\n}"
}, {
  time: time
}).steps(intensitySteps).resample({
  source: '#surfaceArea',
  width: 37,
  height: 19,
  items: 2,
  channels: 4,
  paddingWidth: 1,
  paddingHeight: 1
}).vector({
  color: '#40C0FF',
  zBias: 15,
  end: true
});

polar.transition({
  stagger: [-5]
}).steps({
  trigger: 8,
  pace: .7,
  stops: [0, 1],
  script: {
    0: [
      {
        enter: 0.35,
        exit: 0.35
      }
    ],
    1: [
      {
        enter: 1,
        exit: 1
      }
    ]
  }
}).shader({
  id: 'tangent1',
  code: "uniform float time;\nuniform float intensity;\n\nvec4 warpVertex(vec4 xyzw) {\n  xyzw *= vec4(1.0, 0.5, 0.5, 0.0);\n\n  xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));\n  xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));\n  xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));\n  xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));\n\n  xyzw *= vec4(1.0, 2.0, 2.0, 0.0);\n    \n  return xyzw;\n}\n\nvec4 getSample(vec4 xyzw);\nvec4 getVectorSample(vec4 xyzw) {\n  vec4 xyz0 = vec4(xyzw.xyz, 0.0);\n  vec3 c = warpVertex(getSample(xyz0)).xyz;\n  vec3 r = warpVertex(getSample(xyz0 + vec4(1.0, 0.0, 0.0, 0.0))).xyz;\n  return vec4(c + normalize(c - r) * xyzw.w * .15, 0.0);\n}"
}, {
  time: time
}).steps(intensitySteps).resample({
  source: '#surfaceArea',
  width: 37,
  height: 19,
  items: 2,
  channels: 4,
  paddingWidth: 1,
  paddingHeight: 1
}).vector({
  color: '#60D020',
  zBias: 15,
  end: true
}).shader({
  id: 'tangent2',
  code: "uniform float time;\nuniform float intensity;\n\nvec4 warpVertex(vec4 xyzw) {\n  xyzw *= vec4(1.0, 0.5, 0.5, 0.0);\n\n  xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));\n  xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));\n  xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));\n  xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));\n\n  xyzw *= vec4(1.0, 2.0, 2.0, 0.0);\n    \n  return xyzw;\n}\n\nvec4 getSample(vec4 xyzw);\nvec4 getVectorSample(vec4 xyzw) {\n  vec4 xyz0 = vec4(xyzw.xyz, 0.0);\n  vec3 c = warpVertex(getSample(xyz0)).xyz;\n  vec3 u = warpVertex(getSample(xyz0 + vec4(0.0, 1.0, 0.0, 0.0))).xyz;\n  return vec4(c + normalize(c - u) * xyzw.w * .15, 0.0);\n}"
}, {
  time: time
}).steps(intensitySteps).resample({
  source: '#surfaceArea',
  width: 37,
  height: 19,
  items: 2,
  channels: 4,
  paddingWidth: 1,
  paddingHeight: 1
}).vector({
  color: '#F92055',
  zBias: 15,
  end: true
});

view.transform({
  pass: 'data',
  position: [0, π / 2, 0]
}).axis({
  detail: 512
}).scale({
  divide: 10,
  unit: π,
  base: 2
}).ticks({
  width: 3,
  epsilon: 0.001
}).scale({
  divide: 5,
  unit: π,
  base: 2,
  start: false,
  end: true
}).format({
  expr: function(x) {
    return formatNumber(x);
  }
}).label({
  depth: .5,
  zIndex: 1
}).steps({
  stops: [0, 1],
  trigger: 4,
  script: [
    [
      {
        opacity: 1
      }
    ], [
      {
        opacity: 0
      }
    ]
  ]
});

view.axis({
  axis: 2,
  detail: 128
}).scale({
  axis: 2,
  divide: 5,
  unit: π,
  base: 2
}).ticks({
  width: 3,
  epsilon: 0.001
});

view.transform({
  pass: 'data',
  position: [π / 2, 0, 0]
}).axis({
  axis: 2,
  detail: 128
});

view.transform({
  pass: 'data',
  position: [-π / 2, 0, 0]
}).axis({
  axis: 2,
  detail: 128
});

view.grid({
  divideX: 40,
  detailX: 512,
  divideY: 20,
  detailY: 128,
  width: 1,
  opacity: 0.5,
  unitX: π,
  unitY: π,
  baseX: 2,
  zBias: -5
}).interval({
  length: 512,
  channels: 2,
  map: emitCurve
}).line({
  color: '#B94095',
  width: 5,
  zBias: 3
}).steps({
  trigger: 4,
  stops: [0, 1, 2, 3],
  script: [
    [
      {
        opacity: 1,
        color: '#B94095'
      }
    ], [
      {
        opacity: 0
      }
    ], [
      {
        opacity: 1,
        color: '#3090FF'
      }
    ], [
      {
        opacity: .5,
        color: '#3090FF'
      }
    ]
  ]
}).transition({
  stagger: 10
}).steps({
  stops: [0, 1, 0],
  trigger: 4,
  script: [
    [
      {
        enter: 0,
        exit: 1
      }
    ], [
      {
        enter: 1,
        exit: 1
      }
    ]
  ]
}).axis({
  axis: 2,
  detail: 256,
  color: 0x259035,
  width: 5
}).transform({
  pass: 'data',
  position: [0, π / 2, 0]
}).axis({
  axis: 1,
  detail: 512,
  color: 0x3090FF,
  width: 5
}).axis({
  axis: 3,
  detail: 256,
  color: 0xC02050,
  width: 5
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

present.on('change', function(e) {
  var el, k, l, len, len1, len2, m, ref1, ref2, ref3, results, step, surface;
  step = present[0].get('index');
  if (step <= 11) {
    ref1 = document.querySelectorAll('.shadergraph-overlay');
    for (k = 0, len = ref1.length; k < len; k++) {
      el = ref1[k];
      el.remove();
    }
  }
  if (step === 11) {
    surface = mathbox.select('surface')[0];
    if (surface != null) {
      surface.controller.objects[0].objects[0].material.fragmentGraph.inspect();
    }
    ref2 = document.querySelectorAll('.shadergraph-overlay');
    for (l = 0, len1 = ref2.length; l < len1; l++) {
      el = ref2[l];
      enlarge(el, 2);
    }
    ref3 = document.querySelectorAll('.shadergraph-overlay');
    results = [];
    for (m = 0, len2 = ref3.length; m < len2; m++) {
      el = ref3[m];
      results.push(enter(el));
    }
    return results;
  }
});



},{}]},{},[1]);
