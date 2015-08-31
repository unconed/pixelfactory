(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var ASPECT, HEIGHT, WIDTH, deeperred, deepred, enlarge, enter, formatNumber, getOverlays, inTriangle, line1, line2, line3, line4, mathbox, multisampleCanvas, multisampleShader, multisampler, multisamples, pixelCanvas, pixelCanvasRGBA, pixelCanvasText, pixelCanvasTextA, pixelCanvasTextB, pixelCanvasTextG, pixelCanvasTextR, pixelGrid, pixelRTT, pixelRTTRGBA, pixelRTTms1, pixelRTTms2, pixelRTTms3, pixelRTTms4, pixelSlide, pixelView, present, ref, sampleCone, sliceLerp, three, tri, triangle, triangleBuffer, triangleFace, triangleFaceData, triangleOutline, triangleSamplePoint, triangleSamples, triangleSnap, triangleSnapFace, triangleSnapOutline, updateTriangle;

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

deepred = new THREE.Color(0xa00000);

deeperred = new THREE.Color(0x800000);

triangleBuffer = [];

triangle = function(emit, i, t) {
  var theta, x, y;
  theta = i * τ / 3 + t / 8;
  x = Math.sin(theta) * .79;
  y = Math.cos(theta) * .79;
  x = x * 10 + 16;
  y = y * 10 + 10;
  emit(x, y);
  if (i < 3) {
    triangleBuffer[i * 2] = x;
    triangleBuffer[i * 2 + 1] = y;
    if (i === 2) {
      return updateTriangle();
    }
  }
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

tri = new THREE.Triangle;

updateTriangle = (function() {
  var mapX, mapY;
  mapX = function(x) {
    return (x - 16) * HEIGHT / (HEIGHT - 1) + 16;
  };
  mapY = function(y) {
    return (y - 10) * HEIGHT / (HEIGHT - 1) + 10;
  };
  return function() {
    tri.a.set(mapX(triangleBuffer[0]), mapY(triangleBuffer[1]), 0);
    tri.b.set(mapX(triangleBuffer[2]), mapY(triangleBuffer[3]), 0);
    return tri.c.set(mapX(triangleBuffer[4]), mapY(triangleBuffer[5]), 0);
  };
})();

inTriangle = (function() {
  var p;
  p = new THREE.Vector3;
  return function(x, y) {
    p.set(x, y, 0);
    return tri.containsPoint(p);
  };
})();

sampleCone = function(emit, i, j) {
  var theta, x, y, z;
  theta = i * τ / 4 + τ / 8;
  x = Math.cos(theta) * j * .707 + 16.5;
  y = Math.sin(theta) * j * .707 + 10.5;
  z = 7 - j * 14;
  return emit(x, y, z);
};

formatNumber = MathBox.Util.Pretty.number();

WIDTH = 32;

HEIGHT = 20;

ASPECT = WIDTH / HEIGHT;

mathbox.set({
  scale: 720,
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
  duration: 1,
  pace: 1,
  rewind: 2,
  stops: [0, 1, 1.5, 2.5, 4.5, 4.5, 4.5, 4.5, 5.5, 7.5, 9.5, 10.5],
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
        position: [0, -1.1, .6],
        rotation: [1, 0, .3]
      }
    ],
    4.5: [
      {
        position: [0, 0, 4.5],
        rotation: [0, 0, 0],
        lookAt: null
      }
    ],
    5.5: [
      {
        position: [0, 0, 3.5],
        rotation: [0, 0, 0],
        lookAt: [0, 0, 0]
      }
    ],
    7.5: [
      {
        position: [2.5, 0, 0]
      }
    ],
    9.5: [
      {
        position: [0, 0, 3.5]
      }
    ],
    10.5: [
      {
        position: [0, .4, 1.2],
        lookAt: [0, .4, 0]
      }
    ]
  }
}).cartesian({
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
});

pixelView.slide({
  late: 5
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
}).transform().step({
  trigger: 14,
  duration: 2,
  script: [
    [
      {
        position: [0, 0, 0]
      }
    ], [
      {
        position: [0, 0, -7]
      }
    ], [
      {
        position: [0, 0, 0]
      }
    ]
  ]
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
}).end().transform().step({
  trigger: 14,
  duration: 2,
  script: [
    [
      {
        position: [0, 0, 0]
      }
    ], [
      {
        position: [0, 0, -7]
      }
    ], [
      {
        position: [0, 0, 0]
      }
    ]
  ]
}).area({
  width: 2,
  height: 2
}).surface({
  color: 0xFFFFFF,
  map: pixelRTT
}).end().end();

line1 = pixelGrid.slide({
  late: 7
}).reveal({
  duration: .5,
  stagger: [100],
  delayExit: 1
}).view({
  range: [[8, 25], [10, 11]]
}).area({
  width: 2,
  height: 2
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
}).reveal({
  duration: .5,
  delayExit: 1,
  stagger: [0, 100]
}).view({
  range: [[15, 17], [4, 20]]
}).area({
  width: 2,
  height: 2
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
}).reveal({
  duration: .5,
  delayExit: 1,
  stagger: [0, 100]
}).transform({
  rotation: [0, 0, 1.2],
  position: [19.5, 10]
}).view({
  range: [[0, 1], [0, 9.9]]
}).area({
  width: 2,
  height: 2
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
  delayExit: 1,
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
  size: 6.5,
  outline: .7,
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
  size: 6.5,
  outline: .7,
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
  size: 6.5,
  outline: .7,
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
  size: 6.5,
  outline: .7,
  depth: .8
});

triangleSnapFace = pixelGrid.slide({
  steps: 0,
  from: 10,
  to: 12
}).reveal({
  delayEnter: 2,
  duration: .5
}).array({
  channels: 2,
  length: 3,
  expr: triangleSnap
}).transpose({
  order: 'yzwx'
}).face({
  color: deeperred,
  zBias: 5
}).step({
  duration: .5,
  script: [
    [
      {
        opacity: 1
      }
    ], [
      {
        opacity: .5
      }
    ]
  ]
});

triangleSnapOutline = pixelView.slide({
  steps: 0,
  from: 11,
  to: 12
}).reveal({
  duration: .5
}).array({
  channels: 2,
  length: 4,
  expr: triangleSnap
}).line({
  color: deepred,
  width: 10,
  zBias: 10
}).slice({
  width: [0, 3]
}).point({
  color: deepred,
  size: 30,
  zBias: 15
});

triangleFaceData = pixelGrid.slide({
  steps: 0,
  from: 12,
  to: 20
}).reveal({
  duration: 1
}).array({
  channels: 2,
  length: 3,
  expr: triangle
}).transpose({
  order: 'yzwx'
});

triangleFace = triangleFaceData.face({
  color: deeperred,
  opacity: .5,
  zBias: 5
});

triangleOutline = pixelView.slide({
  steps: 0,
  from: 12,
  to: 20
}).reveal({
  duration: 1
}).transform().step({
  trigger: 2,
  duration: 2,
  script: [
    [
      {
        position: [0, 0, 0]
      }
    ], [
      {
        position: [0, 0, 7]
      }
    ], [
      {
        position: [0, 0, 0]
      }
    ]
  ]
}).array({
  channels: 2,
  length: 4,
  expr: triangle
}).line({
  color: deepred,
  width: 10,
  zBias: 10
}).slice({
  width: [0, 3]
}).point({
  color: deepred,
  size: 30,
  zBias: 15
}).transpose({
  order: 'yzwx'
}).face({
  color: deepred,
  zBias: 8,
  zOrder: -3
}).step({
  trigger: 2,
  duration: 1,
  stops: [0, 2, 4],
  script: [
    [
      {
        opacity: 0
      }
    ], [
      {
        opacity: 0
      }
    ], [
      {
        opacity: .25
      }
    ], [
      {
        opacity: 0
      }
    ], [
      {
        opacity: 0
      }
    ]
  ]
});

multisamples = [[.375, .125], [-.125, .375], [.125, -.375], [-.375, -.125]];

sliceLerp = 0;

triangleSamples = pixelView.slide({
  steps: 0,
  from: 13,
  to: 20
}).reveal({
  duration: 1,
  stagger: [3, 3]
}).area({
  width: WIDTH,
  height: HEIGHT,
  centeredX: true,
  centeredY: true,
  items: 4,
  expr: function(emit, x, y, i, j) {
    var k, l;
    for (k = l = 0; l <= 3; k = ++l) {
      emit(x, y, 0, 0);
    }
  }
}).step({
  trigger: 4,
  duration: 1,
  script: [
    [
      {
        expr: function(emit, x, y, i, j) {
          var k, l;
          for (k = l = 0; l <= 3; k = ++l) {
            emit(x, y, 0, 0);
          }
        }
      }
    ], [
      {
        expr: function(emit, x, y, i, j) {
          var k, l, ms, xx, yy;
          for (k = l = 0; l <= 3; k = ++l) {
            ms = multisamples[k];
            xx = x + ms[0];
            yy = y + ms[1];
            emit(xx, yy, 0, 0);
          }
        }
      }
    ]
  ]
}).slice().step({
  trigger: 4,
  duration: 1,
  script: {
    0: [
      {
        items: [0, 1]
      }
    ],
    0.01: [
      {
        items: [0, 4]
      }
    ]
  }
}).area({
  width: WIDTH,
  height: HEIGHT,
  items: 4,
  expr: function(emit, x, y, i, j) {
    var inside, k, l, results;
    results = [];
    for (k = l = 0; l <= 3; k = ++l) {
      inside = inTriangle(x, y);
      if (inside) {
        results.push(emit(deepred.r, deepred.g, deepred.b, 1));
      } else {
        results.push(emit(.5, .5, .5, 1));
      }
    }
    return results;
  }
}).step({
  trigger: 4,
  duration: 1,
  script: [
    [
      {
        expr: function(emit, x, y, i, j) {
          var inside, k, l, results;
          results = [];
          for (k = l = 0; l <= 3; k = ++l) {
            inside = inTriangle(x, y);
            if (inside) {
              results.push(emit(deepred.r, deepred.g, deepred.b, 1));
            } else {
              results.push(emit(.5, .5, .5, 1));
            }
          }
          return results;
        }
      }
    ], [
      {
        expr: function(emit, x, y, i, j) {
          var inside, k, l, ms, results, xx, yy;
          results = [];
          for (k = l = 0; l <= 3; k = ++l) {
            ms = multisamples[k];
            xx = x + ms[0];
            yy = y + ms[1];
            inside = inTriangle(xx, yy);
            if (inside) {
              results.push(emit(deepred.r, deepred.g, deepred.b, 1));
            } else {
              results.push(emit(.5, .5, .5, 1));
            }
          }
          return results;
        }
      }
    ]
  ]
}).slice().step({
  trigger: 4,
  duration: 0,
  script: {
    0: [
      {
        items: [0, 1]
      }
    ],
    0.01: [
      {
        items: [0, 4]
      }
    ]
  }
});

triangleSamplePoint = triangleSamples.transform().step({
  duration: 2,
  script: [
    [
      {
        position: [0, 0, 0]
      }
    ], [
      {
        position: [0, 0, 7]
      }
    ], [
      {
        position: [0, 0, 0]
      }
    ]
  ]
}).point({
  color: 0xffffff,
  points: "<<<",
  colors: "<",
  size: 10.5,
  zIndex: 1,
  zBias: 6,
  zOrder: -2
}).step({
  trigger: 4,
  duration: 1,
  script: {
    0: [
      {
        size: 10.5
      }
    ],
    1: [
      {
        size: 7
      }
    ]
  }
});

sampleCone = pixelView.slide({
  steps: 0,
  from: 14,
  to: 15
}).reveal({
  stagger: [0, 5],
  durationEnter: 2,
  durationExit: 1
}).transform().step({
  trigger: 0,
  duration: 2,
  script: [
    [
      {
        scale: [1, 1, 0]
      }
    ], [
      {
        scale: [1, 1, 1]
      }
    ], [
      {
        scale: [1, 1, 0]
      }
    ]
  ]
}).matrix({
  channels: 3,
  width: 5,
  height: 2,
  expr: sampleCone
}).surface({
  color: deepred,
  zBias: 5,
  zOrder: -2,
  zIndex: 1,
  opacity: .5
}).surface({
  fill: false,
  lineX: true,
  lineY: true,
  color: deeperred,
  width: 3,
  zBias: 5,
  zOrder: -3,
  zIndex: 1,
  opacity: .5
});

pixelRTTms1 = pixelView.rtt({
  width: WIDTH,
  height: HEIGHT,
  minFilter: 'nearest',
  magFilter: 'nearest'
});

pixelRTTms1.camera({
  position: [0, 0, 1],
  fov: 90
}).cartesian({
  position: [multisamples[0][0] / HEIGHT * 2, multisamples[0][1] / HEIGHT * 2],
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
}).face({
  points: triangleFaceData,
  color: deeperred,
  opacity: .5,
  zBias: 5
});

pixelRTTms2 = pixelView.rtt({
  width: WIDTH,
  height: HEIGHT,
  minFilter: 'nearest',
  magFilter: 'nearest'
});

pixelRTTms2.camera({
  position: [0, 0, 1],
  fov: 90
}).cartesian({
  position: [multisamples[1][0] / HEIGHT * 2, multisamples[1][1] / HEIGHT * 2],
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
}).face({
  points: triangleFaceData,
  color: deeperred,
  opacity: .5,
  zBias: 5
});

pixelRTTms3 = pixelView.rtt({
  width: WIDTH,
  height: HEIGHT,
  minFilter: 'nearest',
  magFilter: 'nearest'
});

pixelRTTms3.camera({
  position: [0, 0, 1],
  fov: 90
}).cartesian({
  position: [multisamples[2][0] / HEIGHT * 2, multisamples[2][1] / HEIGHT * 2],
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
}).face({
  points: triangleFaceData,
  color: deeperred,
  opacity: .5,
  zBias: 5
});

pixelRTTms4 = pixelView.rtt({
  width: WIDTH,
  height: HEIGHT,
  minFilter: 'nearest',
  magFilter: 'nearest'
});

pixelRTTms4.camera({
  position: [0, 0, 1],
  fov: 90
}).cartesian({
  position: [multisamples[3][0] / HEIGHT * 2, multisamples[3][1] / HEIGHT * 2],
  range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]],
  scale: [WIDTH / HEIGHT, 1, 1]
}).face({
  points: triangleFaceData,
  color: deeperred,
  opacity: .5,
  zBias: 5
});

multisampleShader = pixelView.shader({
  sources: [pixelRTTms1, pixelRTTms2, pixelRTTms3, pixelRTTms4],
  code: "vec4 getSample1(vec4 xyzw);\nvec4 getSample2(vec4 xyzw);\nvec4 getSample3(vec4 xyzw);\nvec4 getSample4(vec4 xyzw);\nvec4 getSampleMS(vec4 xyzw) {\n  return .25 * (getSample1(xyzw) + getSample2(xyzw) + getSample3(xyzw) + getSample4(xyzw)); \n}"
});

multisampler = pixelView.resample({
  source: pixelRTTms1,
  shader: multisampleShader
});

multisampleCanvas = pixelView.slide({
  steps: 0,
  from: 17,
  to: 20
}).reveal({
  duration: 1
}).area({
  width: 2,
  height: 2
}).surface({
  color: 0xFFFFFF,
  map: multisampler
});

window.onmessage = function(e) {
  var data;
  data = e.data;
  if (data.type === 'slideshow') {
    return present.set('index', data.i + 1);
  }
};

enlarge = function(el, zoom) {
  var l, len, ref1, results, svg;
  el.style.zoom = zoom;
  ref1 = el.querySelectorAll('.shadergraph-graph');
  results = [];
  for (l = 0, len = ref1.length; l < len; l++) {
    el = ref1[l];
    if (typeof el.update === "function") {
      el.update();
    }
    results.push((function() {
      var len1, m, ref2, results1;
      ref2 = el.querySelectorAll('svg');
      results1 = [];
      for (m = 0, len1 = ref2.length; m < len1; m++) {
        svg = ref2[m];
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
  var i, j, l, ref1, results;
  i = present[0].get('index');
  if (e.total === e.current && i <= 2) {
    results = [];
    for (j = l = ref1 = i; ref1 <= 2 ? l < 2 : l > 2; j = ref1 <= 2 ? ++l : --l) {
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
