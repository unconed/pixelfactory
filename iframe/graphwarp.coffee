window.mathbox =
{mathbox, three} = mathBox
  plugins: ['core']
  time:
    delay: 10
  mathbox:
    warmup: 2
  splash:
    color: 'blue'

MathBox.DOM.Types.latex = MathBox.DOM.createClass
  render: (el, props, children) ->
    props.innerHTML = katex.renderToString children
    el 'span', props

mathbox = mathbox.v2()

three.renderer.setClearColor new THREE.Color(0xFFFFFF), 1.0

formatNumber = MathBox.Util.Pretty.number()

emitCurve = (emit, x, i, t) ->
  emit x, π / 2 + .6  * Math.sin(x + t) +
               .3  * Math.sin(x * 2 + t * 1.81) +
               .1825 * Math.sin(x * 3 + t * 2.18)

emitSurface = (emit, x, y, i, j, t) ->
  emit x, π / 2 + .6  * Math.sin(x + t - y + 2 * Math.sin(y)) +
               .3  * Math.sin(x * 2 + y * 2 + t * 1.81) +
               .1825 * Math.sin(x * 3 - y * 2 + t * 2.18), y

orbit = (t) -> [Math.cos(t / 1) * .5 - 2, 0, 1 + .25 * Math.sin(t / 1)]
time  = (t) -> t / 4

intensitySteps =
  stops: [0, 0, 1, 1, 1, 3, 3, 3, 4, 5, 6, 7]
  duration: 0
  pace:     5
  script: {
    "0":   [{intensity: 0}]
    "0.5": [{intensity: 0}]
    "1":   [{intensity: 2.5}]
    "3":   [{}, {intensity: (t) -> 1.5 + .75 * Math.sin(t * .43) + .75 * Math.sin(t * 1.31) }]
    "4":   [{intensity: 0}]
    "5":   [{}, {intensity: (t) -> Math.cos(t) * .55 }]
    "6":   [{}, {intensity: (t) -> Math.cos(t) * .75 }]
    "7":   [{}, {intensity: (t) -> .75 }]
  }

mathbox
  .set
    scale: 500
    focus: 3

present = mathbox.present
  index: 0

present.slide()

slide = present
  .slide({ id: 'top' })

camera = slide
  .camera()
  .step
    duration: 0
    pace:     5
    stops:    [0, 0, 2, 2, 2, 2, 2, 4, 5, 5, 6, 7]
    script: [
      {key: 0, props: {position: [0, 0, 3], lookAt: [0, 0, 0]}}
      {key: 1, props: {lookAt: [1, 0, -1]}, expr: {position: orbit}}
      {key: 2, props: {lookAt: [1, 0, -1]}, expr: {position: orbit}}
      {key: 4, props: {position: [-1, 0, 1], lookAt: [4, 0, -1]}}
      {key: 5, props: {position: [-1.2, .9, 2.5], lookAt: [0, -.7, -1]}}
      {key: 6, props: {position: [-2.4, 1, 1.2], lookAt: [0, -.9, -1]}}
      {key: 6.2, props: {position: [-2.1, .6, 1.1], lookAt: [0, -.9, -1]}}
    ]
  .step
    target:   'root'
    duration: 0
    pace:     1
    trigger:  4
    stops:    [0, 1, 2, 2, 2, 2, 2, 2, 3, 4, 4, 4, 4, 4, 4, 5]
    realtime: true
    script: [
      [{speed: 1}]
      [{speed: 0}]
      [{speed: 1}]
      [{speed: .5}]
      [{speed: .1}]
      [{speed: 1}]
    ]

warpShader =
slide
  .shader {
    code: """
      uniform float time;
      uniform float intensity;

      vec4 warpVertex(vec4 xyzw, inout vec4 stpq) {
        xyzw *= vec4(1.0, 0.5, 0.5, 0.0);

        xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));
        xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));
        xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));
        xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));
    
        xyzw *= vec4(1.0, 2.0, 2.0, 0.0);
    
        return xyzw;
      }
      """
  }, {
    time: time
  }

slide
  .step intensitySteps

slide
  .slide().end()
  .slide().end()

slide
  .layer()
    .unit
        scale: 500
        focus: 1
      .cartesian
          id: "overlayGraph"
          range: [[-1, 0], [0, 4], [-.5, .5]]
          scale: [1.5, .35, .35]
          position: [0, -.55]
        .slide
            late: 1
            steps: 3
          .reveal
              stagger: [-10]
              durationEnter: 1
              durationExit: .5
              delayExit: .5
            .axis
              axis: 1
              origin: [-1, 0]
              zIndex: 3
            .axis
              axis: 2
              origin: [-1, 0]
              zIndex: 3
            .area
              width:  2
              height: 2
            .surface
              shaded: false
              color: 'white'
              opacity: .95
              zBias: -10
              zOrder: -1
              zIndex: 3
            .grid
              divideX: 15
              divideY: 5
              zIndex: 3
              opacity: .5
          .end()

          .reveal
              stagger: [10]
              durationEnter: 1
              durationExit: .5
            .array
              length: 1
              history: 512
              expr: (emit, i, t) -> emit 0, t % 4
              channels: 2
              fps: 60
              realtime: true
              observe: true
            .spread
              height: -1
              alignHeight: 1
            .transpose
              order: 'yx'
            .line
              width: 3
              color: '#25A035'
              zIndex: 3
              proximity: 1
            .step
              duration: 1
              script: [
                [{opacity: 1}]
                [{opacity: 0.5}]
              ]
            .slice
              width: [0, 1]
            .point
              color: '#25A035'
              size: 9
              zIndex: 4
            .format
              data: ["Time"]
              font: ["klavika-web", "Klavika Web Basic", "sans-serif"]
              style: 'italic'
              weight: 'bold'
              detail: 32
            .label
              color: '#25A035'
              zIndex: 4
              size: 28
              offset: [0, 20]
            .step
              duration: 1
              trigger: 3
              script: [
                [{opacity: 1}]
                [{opacity: 0.5}]
              ]
          .end()
        .end()

        .slide()
          .reveal
              stagger: [10]
              durationEnter: 1
              durationExit:  1
            .array
              length: 1
              history: 512
              expr: (emit, i, t) -> emit 0, warpShader.evaluate 'intensity', t
              channels: 2
              fps: 60
              hurry: 20
            .spread
              height: -1
              alignHeight: 1
            .transpose
              order: 'yx'
            .line
              width: 3
              color: '#3090FF'
              zIndex: 3
              proximity: 1
            .slice
              width: [0, 1]
            .point
              color: '#3090FF'
              size: 9
              zIndex: 4
            .format
              data: ["Intensity"]
              font: ["klavika-web", "Klavika Web Basic", "sans-serif"]
              style: 'italic'
              weight: 'bold'
              detail: 32
            .label
              color: '#3080FF'
              zIndex: 4
              size: 28
              offset: [0, -20]

slide
  .slide().end()

polar = slide
  .reveal
      stagger: [10, 0, 0, 0]
      durationEnter: 2
      durationExit:  3
    .polar
        bend: .25
        range: [[-π, π], [0, π], [-π / 2, π / 2]]
        scale: [2, 1, 1]

polar
  .step
    stops: [0, 11, 11, 11, 11, 11, 11, 11, 12]
    duration: 0
    pace:     1
    script: {
      0: [{bend: 0}]
      5: [{bend: 1}]
      7: [{bend: 1, quaternion: [0, 1, 0, 0]}]
      11: [{bend: .33, quaternion: [0, 0, 0, -1]}]
      12: [{bend: 0}]
    }

view = polar
    .vertex
        pass: 'data'

subslide = view
  .slide
    id: 'grids'
    late: 2

subslide
  .reveal
      stagger: [10]
      duration: 2
    .transform
        pass: 'data'
        position: [0, π, 0]
      .grid
        opacity: .5
        axes: [1, 3]
        unitX: π
        unitY: π
        baseX: 2
        divideX: 40
        divideY: 10
        detailX: 512
        detailY: 128
        crossed: true
    .end()
      .grid
        opacity: .5
        axes: [1, 3]
        unitX: π
        unitY: π
        baseX: 2
        divideX: 40
        divideY: 10
        detailX: 512
        detailY: 128
        crossed: true

view.slide().end()
view.slide().end()
view.slide().end()
view.slide().end()
view.slide().end()
view.slide().end()
view.slide().end()
view.slide().end()
view.slide().end()

view
  .reveal
      stagger: [-100]
    .step
      trigger: 10
      pace: 1
      stops: [0, 1]
      script: {
        0: [{enter: 0.1, exit: 0.1}]
        1: [{enter: 1,     exit: 1}]
      }
    .area
      id: 'surfaceArea'
      axes: [1, 3]
      width:  193
      height: 97
      channels: 3
      expr: emitSurface
    .surface
      lineX: false
      lineY: false
      zBias: 3
    .step
      trigger: 12
      pace: 1
      stops: [0, 1]
      script: {
        0: [{color: '#3090FF', opacity: 1}]
        1: [{color: '#18487F', opacity: .9}]
      }
    .surface
      lineX: true
      lineY: true
      fill: false
      width: 0
      zBias: 3
    .step
      trigger: 12
      pace: 1
      stops: [0, 1]
      script: {
        0: [{color: '#3090FF', opacity: 1, width: 0}]
        1: [{color: '#3090FF', opacity: .5, width: 1}]
      }

polar
  .reveal
      stagger: [-5]
    .step
      trigger: 11
      pace: 2
      stops: [0, 1]
      script: {
        0: [{enter: 0.1, exit: 0.1}]
        1: [{enter: 1, exit: 1}]
      }
    .shader {
      id: 'normals'
      code: """
      uniform float time;
      uniform float intensity;
      uniform float scale;

      vec4 warpVertex(vec4 xyzw) {
        xyzw *= vec4(1.0, 0.5, 0.5, 0.0);

        xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));
        xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));
        xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));
        xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));

        xyzw *= vec4(1.0, 2.0, 2.0, 0.0);
    
        return xyzw;
      }

      vec4 getSample(vec4 xyzw);
      vec4 getVectorSample(vec4 xyzw) {
        vec4 xyz0 = vec4(xyzw.xyz, 0.0);
        vec3 c = warpVertex(getSample(xyz0)).xyz;
        vec3 r = warpVertex(getSample(xyz0 + vec4(1.0, 0.0, 0.0, 0.0))).xyz;
        vec3 u = warpVertex(getSample(xyz0 + vec4(0.0, 1.0, 0.0, 0.0))).xyz;
        vec3 n = normalize(cross(r - c, u - c));
        return vec4(c - scale * n * xyzw.w, 0.0);
      }
      """
    }, {
      time: time
    }
    .step intensitySteps
    .step
      duration: .2
      trigger: 13
      target: '<<'
      script: {
        0: [{scale: .2}],
        1: [{scale: 0}],
        2: [{scale: 0}],
        3: [{scale: .2}],
        4: [{scale: .2}],
        4.5: [{scale: 0}],
      }
    .resample
      source: '#surfaceArea'
      width: 37
      height: 19
      items: 2
      channels: 4
      paddingWidth:  1
      paddingHeight: 1
    .vector
      color: '#40C0FF'
      #color: '#3090FF'
      zBias: 15
      end: true
    .step
      trigger: 12
      pace: .05
      stops: [0, 1, 1, 2]
      script: {
        0: [{opacity: 1}]
        1: [{opacity: 0}]
        2: [{opacity: 1}]
      }

polar
  .reveal
      stagger: [10]
    .step
      trigger: 13
      pace: .2
      stops: [0, 1]
      script: {
        0: [{enter: 0.001, exit: 0.9}]
        1: [{enter: 1, exit: 1}]
      }
    .shader {
      id: 'tangent1'
      code: """
      uniform float time;
      uniform float intensity;

      vec4 warpVertex(vec4 xyzw) {
        xyzw *= vec4(1.0, 0.5, 0.5, 0.0);

        xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));
        xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));
        xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));
        xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));

        xyzw *= vec4(1.0, 2.0, 2.0, 0.0);
    
        return xyzw;
      }

      vec4 getSample(vec4 xyzw);
      vec4 getVectorSample(vec4 xyzw) {
        vec4 xyz0 = vec4(xyzw.xyz, 0.0);
        vec3 c = warpVertex(getSample(xyz0)).xyz;
        vec3 r = warpVertex(getSample(xyz0 + vec4(1.0, 0.0, 0.0, 0.0))).xyz;
        return vec4(c - normalize(c - r) * xyzw.w * .15, 0.0);
      }
      """
    }, {
      time: time
    }
    .step intensitySteps
    .resample
      source: '#surfaceArea'
      width: 37
      height: 19
      items: 2
      channels: 4
      paddingWidth:  1
      paddingHeight: 1
    .vector
      color: '#46daaf'
      zBias: 25
      end: true
    .step
      trigger: 17
      pace: .1
      script: [
        null,
        [{width: 1, color: '#D0E0FF'}]
      ]

polar
  .reveal
      stagger: [0, -10]
    .step
      trigger: 14
      pace: .2
      stops: [0, 1]
      script: {
        0: [{enter: 0.001, exit: 0.9}]
        1: [{enter: 1, exit: 1}]
      }
    .shader {
      id: 'tangent2'
      code: """
      uniform float time;
      uniform float intensity;

      vec4 warpVertex(vec4 xyzw) {
        xyzw *= vec4(1.0, 0.5, 0.5, 0.0);

        xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));
        xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));
        xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));
        xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));

        xyzw *= vec4(1.0, 2.0, 2.0, 0.0);
    
        return xyzw;
      }

      vec4 getSample(vec4 xyzw);
      vec4 getVectorSample(vec4 xyzw) {
        vec4 xyz0 = vec4(xyzw.xyz, 0.0);
        vec3 c = warpVertex(getSample(xyz0)).xyz;
        vec3 u = warpVertex(getSample(xyz0 + vec4(0.0, 1.0, 0.0, 0.0))).xyz;
        return vec4(c + normalize(c - u) * xyzw.w * .15, 0.0);
      }
      """
    }, {
      time: time
    }
    .step intensitySteps
    .resample
      source: '#surfaceArea'
      width: 37
      height: 19
      items: 2
      channels: 4
      paddingWidth:  1
      paddingHeight: 1
    .vector
      color: '#c089ff'
      zBias: 25
      end: true
    .step
      trigger: 17
      pace: .1
      script: [
        null,
        [{width: 1, color: '#D0E0FF'}]
      ]

polar
  .reveal
      stagger: [-5]
    .step
      trigger: 17
      pace: .1
      stops: [0, 1]
      script: {
        0: [{enter: 0.4, exit: 0.4}]
        1: [{enter: 1, exit: 1}]
      }
    .shader {
      id: 'falsenormal'
      code: """
      uniform float time;
      uniform float intensity;

      vec4 warpVertex(vec4 xyzw) {
        xyzw *= vec4(1.0, 0.5, 0.5, 0.0);

        xyzw +=   0.2 * intensity * (sin(xyzw.yzwx * 1.91 + time + sin(xyzw.wxyz * 1.74 + time)));
        xyzw +=   0.1 * intensity * (sin(xyzw.yzwx * 4.03 + time + sin(xyzw.wxyz * 2.74 + time)));
        xyzw +=  0.05 * intensity * (sin(xyzw.yzwx * 8.39 + time + sin(xyzw.wxyz * 4.18 + time)));
        xyzw += 0.025 * intensity * (sin(xyzw.yzwx * 15.1 + time + sin(xyzw.wxyz * 9.18 + time)));

        xyzw *= vec4(1.0, 2.0, 2.0, 0.0);
    
        return xyzw;
      }

      vec4 getSample(vec4 xyzw);
      vec4 getVectorSample(vec4 xyzw) {
        vec4 xyz0 = vec4(xyzw.xyz, 0.0);
        vec3 c = getSample(xyz0).xyz;
        vec3 r = getSample(xyz0 + vec4(1.0, 0.0, 0.0, 0.0)).xyz;
        vec3 u = getSample(xyz0 + vec4(0.0, 1.0, 0.0, 0.0)).xyz;
        vec3 n = normalize(cross(r - c, u - c));
        return warpVertex(vec4(c - .15 * n * xyzw.w, 0.0));
      }
      """
    }, {
      time: time
    }
    .step intensitySteps
    .resample
      source: '#surfaceArea'
      width: 37
      height: 19
      items: 2
      channels: 4
      paddingWidth:  1
      paddingHeight: 1
    .vector
      width: 1
      color: '#D0E0FF'
      zBias: 15
      end: true

view
  .transform
      pass: 'data'
      position: [0, π / 2, 0]
    .axis
      detail: 512
    .scale
      divide: 10
      unit: π
      base: 2
    .ticks
      width: 3
      epsilon: 0.001
    .scale
      divide: 5
      unit: π
      base: 2
      start: false
      end:   true
    .format
      expr: (x) -> formatNumber x
      font: ["klavika-web", "Klavika Web Basic", "sans-serif"]
    .label
      depth: .5
      zIndex: 1
    .step
      stops: [0, 1]
      trigger: 3
      script: [
        [{opacity: 1}]
        [{opacity: 0}]
      ]

view
  .axis
    axis: 2,
    detail: 128
    crossed: true
  .scale
    axis: 2
    divide: 5
    unit: π
    base: 2
  .ticks
    width: 3
    epsilon: 0.001

view
  .transform
      pass: 'data'
      position: [π / 2, 0, 0]
    .axis
      axis: 2
      detail: 128
      crossed: true

view
  .transform
      pass: 'data'
      position: [-π / 2, 0, 0]
    .axis
      axis: 2,
      detail: 128
      crossed: true

view
  .grid
    divideX: 40
    detailX: 512
    divideY: 20
    detailY: 128
    width: 1
    opacity: 0.5
    unitX: π
    unitY: π
    baseX: 2
    zBias: -5
    crossed: true
  .interval
    length: 512
    channels: 2
    expr: emitCurve
  .line
    color: '#B94095'
    width: 5
    zBias: 3
  .step
    trigger: 8
    stops: [0, 1, 2, 3]
    script: [
      [{opacity: 1, color: '#B94095'}]
      [{opacity: 0}]
      [{opacity: 1, color: '#B94095'}]
      [{opacity: .5, color: '#3090FF'}]
    ]
  .reveal
      id: "primary-axes"
      stagger: 10
    .step
      stops: [0, 1, 0]
      trigger: 8
      script: [
        [{enter: 0, exit: 1}]
        [{enter: 1, exit: 1}]
      ]
    .axis
      axis: 2
      detail: 256
      color: 0x40C020
      width: 5
      zBias: 5
      zOrder: -1
      origin: [0, π / 2, 0]
    .axis
      axis: 1
      detail: 512
      color: 0x3090FF
      width: 5
      zBias: 5
      zOrder: -1
      origin: [0, π / 2, 0]
    .axis
      axis: 3
      detail: 256
      color: 0xC02050
      width: 5
      zBias: 5
      zOrder: -1
      origin: [0, π / 2, 0]

    .scale
      axis: 1
      divide: 2
      origin: [0, π / 2, 0]
    .slice
      width: [0, 0]
    .format
      data: ["x"]
    .label
      color: 0x3080FF
    .scale
      axis: 2
      divide: 2
      origin: [0, π / 2, 0]
    .slice
      width: [0, 0]
    .format
      data: ["y"]
    .label
      color: 0x40A020
    .scale
      axis: 3
      divide: 2
      origin: [0, π / 2, 0]
    .slice
      width: [0, 0]
    .format
      data: ["z"]
    .label
      color: 0xC02050

window.onmessage = (e) ->
  {data} = e
  if data.type == 'slideshow'
    console.log 'slideshow msg', data.i
    present.set 'index', data.i + 1

enlarge = (el, zoom) ->
  el.style.zoom = zoom
  for el in el.querySelectorAll('.shadergraph-graph')
    el.update?()
    for svg in el.querySelectorAll('svg')
      svg.setAttribute 'height', svg.getAttribute('height') * zoom

enter = (el) ->
  setTimeout () ->
    el.classList.add 'slide-delay-2'
    el.classList.add 'slide-active'

three.on 'mathbox/progress', (e) ->
  i = present[0].get('index')

  if e.total == e.current and i <= 2
    for j in [i...2]
      window.parent.postMessage {type: 'slideshow', method: 'next'}, '*'

getOverlays = () ->
  document.querySelectorAll('.shadergraph-overlay')

present.on 'change', (e) ->
  step = present[0].get('index')
  if step <= 20
    el.remove() for el in getOverlays()
  if step == 20
    surface = mathbox.select('surface')[0]
    surface?.controller.objects[0].renders[0].material.fragmentGraph.inspect()
    for el in getOverlays()
      enlarge el, 2
      enter   el

if window == top
  window.onkeydown = (e) ->
    switch e.keyCode
      when 37, 38 then present[0].set 'index', present[0].get('index') - 1
      when 39, 40 then present[0].set 'index', present[0].get('index') + 1
