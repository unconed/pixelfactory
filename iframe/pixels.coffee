window.mathbox =
{mathbox, three} = mathBox
  plugins: ['core', 'cursor']
  time:
    delay: 10
  mathbox:
    warmup: 2
  splash:
    color: 'blue'
  controls:
    klass: THREE.OrbitControls
    parameters:
      noKeys: true
window.three = three

MathBox.DOM.Types.latex = MathBox.DOM.createClass
  render: (el, props, children) ->
    props.innerHTML = katex.renderToString children
    el 'span', props

mathbox = mathbox.v2()

three.renderer.setClearColor new THREE.Color(0xFFFFFF), 1.0

# ====================================================================================

deepred = 0xa00000

# ====================================================================================

triangle = (emit, i, t) ->
  theta = i * τ / 3 + t / 4
  x = Math.sin(theta) * .8
  y = Math.cos(theta) * .8
  emit x * 10 + 16, y * 10 + 10

triangleSnap = (emit, i, t) ->
  _emit = (x, y) ->
    x = Math.round(x - .5) + .5
    y = Math.round(y - .5) + .5
    emit x, y
  triangle _emit, i, t

formatNumber = MathBox.Util.Pretty.number()

WIDTH  = 32
HEIGHT = 20
ASPECT = WIDTH / HEIGHT

# ====================================================================================

mathbox
.set
  focus: 4

present =
  mathbox
  .present
    index: 0

present.slide()

# ====================================================================================

pixelSlide =
  present
  .slide()

pixelView =
  pixelSlide
  .camera
    proxy: true
    position: [0, 0, 4.5]
    fov: 30
  .step
    trigger: 6
    duration: 2
    stops: [0, 1, 1.5, 2.5, 4.5]
    script: {
      0:   [{position: [0, 0, 4.5], rotation: [0, 0, 0]}]
      1:   [{position: [0, .2, 2]}]
      1.5: [{position: [0, .2, .75]}]
      2.5:   [{position: [0, -1.2, .75], rotation: [1, 0, .3]}]
      4.5:   [{position: [0, 0, 4.5], rotation: [0, 0, 0]}]
    }

  .cartesian
      range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
      scale: [WIDTH / HEIGHT, 1, 1]

pixelView
.slide
    late: Infinity
  .reveal
      stagger: [5]
      duration: .5
    .axis
      axis: 1
      width: 5
      color: 0
      zBias: 20
      color: 0x3080FF
    .axis
      axis: 2
      width: 5
      color: 0
      crossed: true
      zBias: 20
      color: 0x40A020

# ====================================================================================

pixelRTT =
  pixelView
  .rtt
    width:  WIDTH
    height: HEIGHT
    minFilter: 'nearest'
    magFilter: 'nearest'

pixelRTTRGBA =
  pixelRTT
  .shader
    code: """
    uniform float split;
    vec4 getSample(vec4 xyzw);
    vec4 splitChannelsRGBA(vec4 xyzw) {
      
      vec4 rgba = getSample(xyzw);
      vec2 xy = fract(xyzw.xy + .5);

      const float alpha = 1.0;
      vec2 uv = xy - .5;
      if (dot(uv, uv) < split) {
        return vec4(rgba.xyz, alpha);
      }

      if (xy.x < .5) {
        if (xy.y < .5) {
          return vec4(0.0, 0.0, rgba.b, alpha);
        }
        else {
          return vec4(rgba.r, 0.0, 0.0, alpha);
        }  
      }
      else {
        if (xy.y < .5) {
          return vec4(vec3(1.0 - rgba.a), alpha);
        }
        else {
          return vec4(0.0, rgba.g, 0.0, alpha);
        }  
      }
    }
    """
  .step
    trigger: 7
    duration: 2,
    stops: [-1, 1, 1, 2]
    script: [
      [{split: 0}]
      [{split: .04}]
      [{split: 0}]
    ]
  .resample()

pixelRTT
.camera
  position: [0, 0, 1]
  fov: 90

pixelGrid =
  pixelRTT
  .cartesian
      range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
      scale: [WIDTH / HEIGHT, 1, 1]

# ====================================================================================

pixelCanvas =
  pixelView
  .reveal
      stagger: [5]
      duration: 1
    .grid
      divideX: WIDTH
      divideY: HEIGHT
      width: 2
      crossed: true
      zBias: 15
      color: 0
    .step
      trigger: 6
      duration: 2
      stops: [0, 1, 1, 1, 2]
      script:[
        [{width: 2, opacity: .5}]
        [{width: 4, opacity: 1}]
        [{width: 2, opacity: .5}]
      ]
    .area
      width:  2
      height: 2
    .surface
      color: 0xFFFFFF
      map: pixelRTT
  .end()

# ====================================================================================

line1 =
  pixelGrid
  .slide
      late: 7
    .view
        range: [[8, 25], [10, 11]]
      .area
        width: 2
        height: 2
      .grow
        width: 'first'
      .step
        trigger: 0
        duration: .5
        script: [
          [{scale: 0}]
          [{scale: 1}]
        ]
      .surface
        color: 0x2090FF
      .step
        trigger: 6
        delay: 2.5
        duration: 3
        stops: [0, 1]
        script: [
          [{opacity: 1}]
          [{}, {opacity: (t) -> .5 - .5 * Math.cos(t * .78) }]
        ]
# ====================================================================================

line2 =
  pixelGrid
  .slide
      late: 6
    .view
        range: [[15, 17], [4, 20]]
      .area
        width: 2
        height: 2
      .grow
        height: 'first'
      .step
        trigger: 0
        duration: .5
        script: [
          [{scale: 0}]
          [{scale: 1}]
        ]
      .surface
        color: 0xC02070
      .step
        trigger: 5
        delay: 2.5
        duration: 3
        stops: [0, 1]
        script: [
          [{opacity: 1}]
          [{}, {opacity: (t) -> .5 - .5 * Math.cos(t * .65) }]
        ]
# ====================================================================================

line3 =
  pixelGrid
  .slide
      late: 5
    .transform
        rotation: [0, 0, 1.2]
        position: [19.5, 10]
      .view
          range: [[0, 1], [0, 9.9]]
        .area
          width: 2
          height: 2
        .grow
          height: 'first'
        .step
          trigger: 0
          duration: .5
          script: [
            [{scale: 0}]
            [{scale: 1}]
          ]
        .surface
          color: 0x8040B0
        .step
          trigger: 4
          delay: 2.5
          duration: 3
          stops: [0, 1]
          script: [
            [{opacity: 1}]
            [{}, {opacity: (t) -> .5 - .5 * Math.cos(t * .81) }]
          ]
# ====================================================================================

line4 =
  pixelGrid
  .slide
      late: 4
    .reveal
        duration: .5
        stagger: [0, 10000]
      .view
          range: [[7, 25], [18, 5]]
        .area
          width: 2
          height: 2
        .matrix
          width: 2
          height: 2
          expr: (emit, i, j) ->
            c = j
            emit 0, .25, .5, c
        .surface
          points: '<<'
          colors: '<'
          color: 0xffffff
        .step
          trigger: 3
          delay: 2.5
          duration: 3
          stops: [0, 1]
          script: [
            [{opacity: 1}]
            [{}, {opacity: (t) -> .5 - .5 * Math.cos(t) }]
          ]
# ====================================================================================

pixelCanvasRGBA =
  pixelView
  .slide
      late: 3
    .reveal
        stagger: [5]
        delayEnter: 1
        duration: 1
      .area
        width:  2
        height: 2
      .surface
        color: 0xFFFFFF
        map: pixelRTTRGBA
        zBias: 5
        zOrder: -100

# ====================================================================================

pixelCanvasText =
  pixelView
  .slide
      late: 1
    .reveal
      stagger: [2]
      delayEnter: 1
      duration: 1

pixelCanvasTextR =
  pixelCanvasText
  .area
    width:  WIDTH
    height: HEIGHT
    centeredX: true
    centeredY: true
  .text
    width: 256
    weight: 'bold'
    expr: (emit, i) -> emit i
  .shader
    sources: pixelRTT
    code: """
    vec4 getColorSample(vec4 xyzw);
    vec4 getTextSample(vec4 xyzw);

    vec4 resample(vec4 xyzw) {          
      vec4 rgba = getColorSample(xyzw);
      float i   = floor(rgba.r * 255.0 + .5);
      return getTextSample(vec4(i, 0, 0, 0));
    }
    """
  .retext
    sample: 'absolute'
    width: WIDTH
    height: HEIGHT
  .transform
      position: [-.24, .24]
    .label
      offset: [0, 0]
      background: 0
      color: 0xFF8080
      zIndex: 1
      zBias: 5
      zOrder: -100
      size: 8
      outline: 1
      depth: .8

pixelCanvasTextG =
  pixelCanvasText
  .area
    width:  WIDTH
    height: HEIGHT
    centeredX: true
    centeredY: true
  .text
    width: 256
    weight: 'bold'
    expr: (emit, i) -> emit i
  .shader
    sources: pixelRTT
    code: """
    vec4 getColorSample(vec4 xyzw);
    vec4 getTextSample(vec4 xyzw);

    vec4 resample(vec4 xyzw) {          
      vec4 rgba = getColorSample(xyzw);
      float i   = floor(rgba.g * 255.0 + .5);
      return getTextSample(vec4(i, 0, 0, 0));
    }
    """
  .retext
    sample: 'absolute'
    width: WIDTH
    height: HEIGHT
  .transform
      position: [.24, .24]
    .label
      offset: [0, 0]
      background: 0
      color: 0x80FF80
      zIndex: 1
      zBias: 5
      zOrder: -100
      size: 8
      outline: 1
      depth: .8

pixelCanvasTextB =
  pixelCanvasText
  .area
    width:  WIDTH
    height: HEIGHT
    centeredX: true
    centeredY: true
  .text
    width: 256
    weight: 'bold'
    expr: (emit, i) -> emit i
  .shader
    sources: pixelRTT
    code: """
    vec4 getColorSample(vec4 xyzw);
    vec4 getTextSample(vec4 xyzw);

    vec4 resample(vec4 xyzw) {          
      vec4 rgba = getColorSample(xyzw);
      float i   = floor(rgba.b * 255.0 + .5);
      return getTextSample(vec4(i, 0, 0, 0));
    }
    """
  .retext
    sample: 'absolute'
    width: WIDTH
    height: HEIGHT
  .transform
      position: [-.24, -.24]
    .label
      offset: [0, 0]
      background: 0
      color: 0xA0A0FF
      zIndex: 1
      zBias: 5
      zOrder: -100
      size: 8
      outline: 1
      depth: .8

pixelCanvasTextA =
  pixelCanvasText
  .area
    width:  WIDTH
    height: HEIGHT
    centeredX: true
    centeredY: true
  .text
    width: 256
    weight: 'bold'
    expr: (emit, i) -> emit i
  .shader
    sources: pixelRTT
    code: """
    vec4 getColorSample(vec4 xyzw);
    vec4 getTextSample(vec4 xyzw);

    vec4 resample(vec4 xyzw) {          
      vec4 rgba = getColorSample(xyzw);
      float i   = floor(rgba.a * 255.0 + .5);
      return getTextSample(vec4(i, 0, 0, 0));
    }
    """
  .retext
    sample: 'absolute'
    width: WIDTH
    height: HEIGHT
  .transform
      position: [.24, -.24]
    .label
      offset: [0, 0]
      background: 0
      color: 0x808080
      zIndex: 1
      zBias: 5
      zOrder: -100
      size: 8
      outline: 1
      depth: .8

# ====================================================================================

triangleSnapFace =
  pixelGrid
  .slide
      steps: 0
      from: 10
      to: 12
    .reveal
        delayEnter: .5
        duration: 1
      .array
        channels: 2
        length: 3
        expr: triangleSnap
      .transpose
        order: 'yzwx'
      .face
        color: 0
        opacity: .5

triangleSnapOutline =
  pixelView
  .slide
      steps: 0
      from: 11
      to: 12
    .reveal
        duration: 1
      .array
        channels: 2
        length: 4
        expr: triangleSnap
      .line
        color: deepred
        width: 10
      .slice
        width: [0, 3]
      .point
        color: deepred
        size: 30

triangleFace =
  pixelGrid
  .slide
      steps: 0
      from: 12
      to: 14
    .reveal
        duration: 1
      .array
        channels: 2
        length: 3
        expr: triangle
      .transpose
        order: 'yzwx'
      .face
        color: 0
        opacity: .5

triangleSnap =
  pixelView
  .slide
      steps: 0
      from: 12
      to: 14
    .reveal
        duration: 1
      .array
        channels: 2
        length: 4
        expr: triangle
      .line
        color: deepred
        width: 10
      .slice
        width: [0, 3]
      .point
        color: deepred
        size: 30

# ====================================================================================

window.onmessage = (e) ->
  {data} = e
  if data.type == 'slideshow'
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
  ###
  if step == 19 or step == 21
    el.remove() for el in getOverlays()
  if step == 20
    surface = mathbox.select('vector')[0]
    surface?.controller.objects[0].renders[0].material.fragmentGraph.inspect()
    for el in getOverlays()
      enlarge el, 2
      enter   el
  ###

if window == top
  window.onkeydown = (e) ->
    switch e.keyCode
      when 37, 38 then present[0].set 'index', present[0].get('index') - 1
      when 39, 40 then present[0].set 'index', present[0].get('index') + 1
