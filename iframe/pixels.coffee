window.mathbox =
{mathbox, three} = mathBox
  plugins: ['core', 'cursor']
  size:
    scale: 1
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

deepred    = new THREE.Color(0xa00000)
deeperred  = new THREE.Color(0x800000)
deeperblue = new THREE.Color(0x000080)

red        = new THREE.Color(0xC02050)
blue       = new THREE.Color(0x3090FF)

# ====================================================================================

triangleBuffer = []

triangle = (emit, i, t) ->
  theta = i * τ / 3 + t / 8
  x = Math.sin(theta) * .77
  y = Math.cos(theta) * .77
  x = x * 10 + 16
  y = y * 10 + 10

  emit x, y

  if i < 3
    triangleBuffer[i*2]   = x
    triangleBuffer[i*2+1] = y
    if i == 2
      updateTriangle()

triangleSnap = (emit, i, t) ->
  _emit = (x, y) ->
    x = Math.round(x - .5) + .5
    y = Math.round(y - .5) + .5
    emit x, y
  triangle _emit, i, t

tri = new THREE.Triangle
updateTriangle = do ->
  mapX = (x) -> (x - 16) * HEIGHT / (HEIGHT - 1) + 16
  mapY = (y) -> (y - 10) * HEIGHT / (HEIGHT - 1) + 10

  () ->
    tri.a.set mapX(triangleBuffer[0]), mapY(triangleBuffer[1]), 0
    tri.b.set mapX(triangleBuffer[2]), mapY(triangleBuffer[3]), 0
    tri.c.set mapX(triangleBuffer[4]), mapY(triangleBuffer[5]), 0

inTriangle = do ->
  p = new THREE.Vector3
  (x, y) ->
    p.set x, y, 0
    tri.containsPoint p

sampleCone = (emit, i, j) ->
  theta = i * τ / 4 + τ / 8
  x = Math.cos(theta) * j * .707 + 16.5
  y = Math.sin(theta) * j * .707 + 10.5
  z = 7 - j * 14
  emit x, y, z

nyquistX  = (x) -> (x - WIDTH / 2) * (WIDTH - 1) / (WIDTH) + WIDTH / 2
nyquistXi = (x) -> (x - WIDTH / 2) / (WIDTH - 1) * (WIDTH) + WIDTH / 2

nyquistSampler = (x, t) ->
  freq = nyquistShader.props.frequency
  Math.cos((x - WIDTH / 2) * (WIDTH - 1) / (WIDTH) * π * freq + t) * .5 + .5

formatNumber = MathBox.Util.Pretty.number()

triangleRel = (emit, i, t) ->
  theta = i * τ / 3 + t / 8
  x = Math.sin(theta) * .75
  y = Math.cos(theta) * .75
  emit x, y, 0

WIDTH  = 32
HEIGHT = 20
ASPECT = WIDTH / HEIGHT

# ====================================================================================

mathbox
.set
  scale: 720
  focus: 4

depthVertex =
  mathbox
  .shader
    code: """
    varying float vDepth;
    vec4 getPosition(vec4 xyzw, inout vec4 stpq) {
      float z = xyzw.z * -1.0;
      vDepth = z * .5;
      return xyzw;
    }
    """

depthFragment =
  mathbox
  .shader
    code: """
    varying float vDepth;
    vec4 getFragDepth(vec4 rgba, inout vec4 stpq) {
      return vec4(vec3(vDepth), 1.0);
    }
    """

present =
  mathbox
  .present
    index: 0

present.slide()

# ====================================================================================

pixelSlide =
  present
  .slide
    to: 31

pixelView =
  pixelSlide
  .camera
    proxy: true
    position: [0, 0, 4.5]
    fov: 30
  .step
    trigger: 6
    duration: 1
    pace: 1
    rewind: 2
    stops: [0, 1, 1.5, 2.5, 4.5, 4.5, 4.5, 4.5, 5.5, 7.5, 9.5, 9.5, 10.5, 10.5, 10.5, 12, 12, 12, 12, 12, 12, 13, 14, 15, 15, 15]
    script: {
      0:    [{position: [0, 0, 4.5], rotation: [0, 0, 0], quaternion: [0, 0, 0, 1]}]
      1:    [{position: [0, .2, 2]}]
      1.5:  [{position: [0, .2, .75]}]
      2.5:  [{position: [0, -1.1, .6], rotation: [1, 0, .3]}]
      4.5:  [{position: [0, 0, 4.5], rotation: [0, 0, 0], lookAt: null}]
      5.5:  [{position: [0, 0, 3.5], rotation: [0, 0, 0], lookAt: [0, 0, 0]}]
      7.5:  [{position: [2.5, 0, 0]}]
      9.5:  [{position: [0, 0, 3.5]}]
      10.5: [{position: [0, .4, 1.2], lookAt: [0, .4, 0]}]
      12:   [{position: [0, .3, .4], lookAt: [0, .3, 0], quaternion: [.5, 0, 0, .833]}]
      13:   [{quaternion: [.65, 0, 0, .76], lookAt: [0, 0, 0], position: [0, 0, .5]}]
      14:   [{quaternion: [.65, 0, 0, .76], lookAt: [0, 0, 0]}, {position: ((t) -> [Math.cos(t) * .13, 0, .5])}]
      15:   [{quaternion: [0, 0, 0, 1], position: [0, 0, 4.5], lookAt: [0, 0, 0]}]
    }

  .cartesian
      range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
      scale: [WIDTH / HEIGHT, 1, 1]
    .step
      trigger: 29
      duration: 2
      script: [
        {rotation: [0, 0, 0], position: [0, 0, 0]}
        {rotation: [-τ / 6, 0, 0], position: [0, -.4, 0]}
      ]

pixelView
.slide
    late: 5
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

pixelRTTLinear =
  pixelView.memo
    minFilter: 'linear'
    magFilter: 'linear'

pixelRTTDepth =
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

pixelRTTDepth
.camera
  position: [0, 0, 1]
  fov: 90

pixelGrid =
  pixelRTT
  .cartesian
      range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
      scale: [WIDTH / HEIGHT, 1, 1]

pixelGridDepth =
  pixelRTTDepth
  .cartesian
      range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
      scale: [WIDTH / HEIGHT, 1, 1]

# ====================================================================================

pixelCanvas =
  pixelView
  .reveal
      stagger: [5]
      duration: 1
    .transform()
      .step
        trigger: 14
        duration: 2
        script: [
          [{position: [0, 0, 0]}]
          [{position: [0, 0, -7]}]
          [{position: [0, 0, 0]}]
        ]
      .grid
        divideX: WIDTH
        divideY: HEIGHT
        width: 2
        crossed: true
        zBias: 15
        zOrder: -1
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
    .end()
    .transform()
      .step
        trigger: 14
        duration: 2
        script: [
          [{position: [0, 0, 0]}]
          [{position: [0, 0, -7]}]
          [{position: [0, 0, 0]}]
        ]
      .area
        width:  2
        height: 2
      .surface
        color: 0xFFFFFF
        map: pixelRTT

      .slide
          steps: 0
          from:  16
          to:    17
        .reveal()
          .area
            width:  2
            height: 2
          .surface
            color: 0xFFFFFF
            map: pixelRTTLinear
    .end()
  .end()

# ====================================================================================

line1 =
  pixelGrid
  .slide
      late: 7
    .reveal
        duration: .5
        stagger: [100]
        delayExit: 1
      .view
          range: [[8, 25], [10, 11]]
        .area
          width: 2
          height: 2
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
    .reveal
        duration: .5
        delayExit: 1
        stagger: [0, 100]
      .view
          range: [[15, 17], [4, 20]]
        .area
          width: 2
          height: 2
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
    .reveal
        duration: .5
        delayExit: 1
        stagger: [0, 100]
      .transform
          rotation: [0, 0, 1.2]
          position: [19.5, 10]
        .view
            range: [[0, 1], [0, 9.9]]
          .area
            width: 2
            height: 2
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
        delayExit: 1
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
      zIndex: 2
      zBias: 5
      zOrder: -100
      size: 6.5
      outline: .7
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
      zIndex: 2
      zBias: 5
      zOrder: -100
      size: 6.5
      outline: .7
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
      zIndex: 2
      zBias: 5
      zOrder: -100
      size: 6.5
      outline: .7
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
      zIndex: 2
      zBias: 5
      zOrder: -100
      size: 6.5
      outline: .7
      depth: .8

# ====================================================================================

triangleSnapFace =
  pixelGrid
  .slide
      steps: 0
      from: 10
      to: 12
    .reveal
        delayEnter: 2
        duration: .5
      .array
        channels: 2
        length: 3
        expr: triangleSnap
      .transpose
        order: 'yzwx'
      .face
        color: deeperred
        zBias: 5
      .step
        duration: .5
        script: [
          [{opacity: 1}]
          [{opacity: .5}]
        ]

triangleSnapOutline =
  pixelView
  .slide
      steps: 0
      from: 11
      to: 12
    .reveal
        duration: .5
      .array
        channels: 2
        length: 4
        expr: triangleSnap
      .line
        color: deepred
        width: 10
        zBias: 10
      .slice
        width: [0, 3]
      .point
        color: deepred
        size: 25
        zBias: 15

# ====================================================================================

triangleFaceData =
  pixelGrid
  .slide
      steps: 0
      from: 12
      to: 20
    .reveal
        duration: 1
      .array
        channels: 2
        length: 3
        expr: triangle
      .transpose
        order: 'yzwx'

triangleFace =
  triangleFaceData
  .face
    color: deeperred
    opacity: .5
    zBias: 5

triangleOutline =
  pixelView
  .slide
      steps: 0
      from: 12
      to: 20
    .reveal
        duration: 1
      .transform()
        .step
          trigger: 2
          duration: 2
          script: [
            [{position: [0, 0, 0]}]
            [{position: [0, 0, 7]}]
            [{position: [0, 0, 0]}]
          ]
        .array
          channels: 2
          length: 4
          expr: triangle
        .line
          color: deepred
          width: 10
          zBias: 10
          zIndex: 1
          zOrder: -1
        .slice
          width: [0, 3]
        .point
          color: deepred
          size: 25
          zBias: 15
          zIndex: 1
          zOrder: -1
        .transpose
          order: 'yzwx'
        .face
          color: deepred
          zBias: 8
          zOrder: -3
        .step
          trigger: 2
          duration: 1
          stops: [0, 2, 4]
          script: [
            [{opacity: 0}]
            [{opacity: 0}]
            [{opacity: .25}]
            [{opacity: 0}]
            [{opacity: 0}]
          ]

# ====================================================================================

multisamples = [
  [.375, .125],
  [-.125, .375],
  [.125, -.375],
  [-.375,-.125],
]

# ====================================================================================

pixelRTTms1 =
  pixelView
  .rtt
      width:  WIDTH
      height: HEIGHT
      minFilter: 'nearest'
      magFilter: 'nearest'

pixelRTTms1
.camera
  position: [0, 0, 1]
  fov: 90
.cartesian
    position: [multisamples[0][0] / HEIGHT * 2, multisamples[0][1] / HEIGHT * 2]
    range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
    scale: [WIDTH / HEIGHT, 1, 1]
  .face
    points: triangleFaceData
    color: deeperred
    opacity: .5
    zBias: 5

pixelRTTms2 =
  pixelView
  .rtt
      width:  WIDTH
      height: HEIGHT
      minFilter: 'nearest'
      magFilter: 'nearest'

pixelRTTms2
.camera
  position: [0, 0, 1]
  fov: 90
.cartesian
    position: [multisamples[1][0] / HEIGHT * 2, multisamples[1][1] / HEIGHT * 2]
    range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
    scale: [WIDTH / HEIGHT, 1, 1]
  .face
    points: triangleFaceData
    color: deeperred
    opacity: .5
    zBias: 5

pixelRTTms3 =
  pixelView
  .rtt
      width:  WIDTH
      height: HEIGHT
      minFilter: 'nearest'
      magFilter: 'nearest'

pixelRTTms3
.camera
  position: [0, 0, 1]
  fov: 90
.cartesian
    position: [multisamples[2][0] / HEIGHT * 2, multisamples[2][1] / HEIGHT * 2]
    range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
    scale: [WIDTH / HEIGHT, 1, 1]
  .face
    points: triangleFaceData
    color: deeperred
    opacity: .5
    zBias: 5

pixelRTTms4 =
  pixelView
  .rtt
      width:  WIDTH
      height: HEIGHT
      minFilter: 'nearest'
      magFilter: 'nearest'

pixelRTTms4
.camera
  position: [0, 0, 1]
  fov: 90
.cartesian
    position: [multisamples[3][0] / HEIGHT * 2, multisamples[3][1] / HEIGHT * 2]
    range: [[0, WIDTH], [0, HEIGHT], [-HEIGHT / 2, HEIGHT / 2]]
    scale: [WIDTH / HEIGHT, 1, 1]
  .face
    points: triangleFaceData
    color: deeperred
    opacity: .5
    zBias: 5

# ====================================================================================

sliceLerp = 0
triangleSamples =
  pixelView
  .slide
      steps: 0
      from: 13
      to: 20
    .reveal
        duration: 1
        stagger: [3, 3]
      .area
        width:  WIDTH
        height: HEIGHT
        centeredX: true
        centeredY: true
        items: 4
        expr: (emit, x, y, i, j) ->
          for k in [0..3]
            emit x, y, 0, 0
          return

      .step
        trigger: 5
        duration: 1
        script: [
          [{
            expr: (emit, x, y, i, j) ->
              for k in [0..3]
                emit x, y, 0, 0
              return
          }],
          [{
            expr: (emit, x, y, i, j) ->
              for k in [0..3]
                ms = multisamples[k]
                xx = x + ms[0]
                yy = y + ms[1]
                emit xx, yy, 0, 0
              return
          }]
        ]
      .shader
        sources: [pixelRTTms1, pixelRTTms2, pixelRTTms3, pixelRTTms4]
        code: """
        uniform float multisample;
        vec4 getSample1(vec4 xyzw);
        vec4 getSample2(vec4 xyzw);
        vec4 getSample3(vec4 xyzw);
        vec4 getSample4(vec4 xyzw);
        vec4 getSamplePos(vec4 xyzw);

        vec4 getSampleMS(vec4 xyzw) {
          if (multisample <= 0.0) {
            return getSamplePos(xyzw);
          }

          vec4 a = getSample1(xyzw);
          vec4 b = getSample2(xyzw);
          vec4 c = getSample3(xyzw);
          vec4 d = getSample4(xyzw);

          vec4 pos = getSamplePos(xyzw);
          
          float diff = length(a - b) + length(c - d) + length(a - c) + length(b - d);
          if (diff > 0.0) {
            return pos;
          }
          else {
            if (multisample >= 1.0 && xyzw.w > 0.0) {
              return vec4(0.0, 0.0, 1000.0, 0.0);
            }
            vec4 avg = .25 * (
              getSamplePos(vec4(xyzw.xyz, 0.0)) +
              getSamplePos(vec4(xyzw.xyz, 1.0)) +
              getSamplePos(vec4(xyzw.xyz, 2.0)) +
              getSamplePos(vec4(xyzw.xyz, 3.0))
            );
            return mix(pos, avg, multisample);
          }
        }
        """
      .step
        trigger: 6
        duration: 1
        script: [
          [{multisample: 0}]
          [{multisample: 1}]
        ]
      .resample()
      .slice()
      .step
        trigger: 5,
        duration: 1
        script: {
          0:     [{items: [0, 1]}]
          0.017: [{items: [0, 4]}]
        }
      .area
        width:  WIDTH
        height: HEIGHT
        items: 4
        expr: (emit, x, y, i, j) ->
          for k in [0..3]
            inside = inTriangle x, y
            if inside
              emit deepred.r, deepred.g, deepred.b, 1
            else
              emit .5, .5, .5, 1

      .step
        trigger: 5
        duration: 1
        script: [
          [{
            expr: (emit, x, y, i, j) ->
              for k in [0..3]
                inside = inTriangle x, y
                if inside
                  emit deepred.r, deepred.g, deepred.b, 1
                else
                  emit .5, .5, .5, 1
          }],
          [{
            expr: (emit, x, y, i, j) ->
              for k in [0..3]
                ms = multisamples[k]
                xx = x + ms[0]
                yy = y + ms[1]

                inside = inTriangle xx, yy
                if inside
                  emit deepred.r, deepred.g, deepred.b, 1
                else
                  emit .5, .5, .5, 1
          }],
        ]

      .slice()
      .step
        trigger: 5,
        duration: 1
        script: {
          0:     [{items: [0, 1]}]
          0.017: [{items: [0, 4]}]
        }

triangleSamplePoint =
  triangleSamples
  .transform()
    .step
      duration: 2
      script: [
        [{position: [0, 0, 0]}]
        [{position: [0, 0, 7]}]
        [{position: [0, 0, 0]}]
      ]

    .point
      color: 0xffffff
      points: "<<<"
      colors: "<"
      size: 10.5
      zIndex: 2
      zBias: 6
      zOrder: -2
    .step
      trigger: 5,
      duration: 1
      script: {
        0: [{size: 10.5}]
        1: [{size: 7}]
      }
# ====================================================================================

sampleCone =
  pixelView
  .slide
      steps: 0
      from: 14
      to: 15
    .reveal
        stagger: [0, 5]
        durationEnter: 2
        durationExit: 1
      .transform()
        .step
          trigger: 0
          duration: 2
          script: [
            [{scale: [1, 1, 0]}]
            [{scale: [1, 1, 1]}]
            [{scale: [1, 1, 0]}]
          ]
        .matrix
          channels: 3
          width:  5
          height: 2
          expr: sampleCone
        .surface
          color: deepred
          zBias: 5
          zOrder: -2
          zIndex: 2
          opacity: .5
        .surface
          fill: false
          lineX: true
          lineY: true
          color: deeperred
          width: 3
          zBias: 5
          zOrder: -3
          zIndex: 2
          opacity: .5

multisampleShader =
  pixelView
  .shader
    sources: [pixelRTTms1, pixelRTTms2, pixelRTTms3, pixelRTTms4]
    code: """
    vec4 getSample1(vec4 xyzw);
    vec4 getSample2(vec4 xyzw);
    vec4 getSample3(vec4 xyzw);
    vec4 getSample4(vec4 xyzw);
    vec4 getSampleMS(vec4 xyzw) {
      return .25 * (getSample1(xyzw) + getSample2(xyzw) + getSample3(xyzw) + getSample4(xyzw)); 
    }
    """

multisampler =
  pixelView
  .resample
    source: pixelRTTms1
    shader: multisampleShader

multisampleCanvas =
  pixelView
  .slide
      steps: 0
      from: 18
      to: 20
    .reveal
        duration: 1
      .area
        width:  2
        height: 2
      .surface
        color: 0xFFFFFF
        map: multisampler

# ====================================================================================

nyquistView =
  pixelView
  .slide
      steps: 0
      from: 20
      to: 27
    .reveal
        stagger: [5]
        delayEnter: 1
        delayExit:  .5
        duration: 2
      .cartesian
          range: [[0, WIDTH], [0, 1], [-.5, .5]]
          scale: [WIDTH / 2, .5, .5]
          position: [WIDTH / 2, HEIGHT, .5]
          rotation: [π / 2, 0, 0]
        .grid
          color: 0x606060
          detailX: 10
          detailY: 3
          divideX: WIDTH
          divideY: 3

        .shader
          id: "nyquistShader"
          code: "uniform float frequency; void main() {};"
        .step
          duration: 2
          script: [
            [{frequency: .5}]
            [{frequency: 1}]
            [{frequency: 2}]
            [{frequency: 3.478}]
            [{frequency: .9}]
            [{frequency: .5}]
            [{frequency: 1}]
          ]

        .interval
          length: WIDTH * 48
          channels: 2
          expr: (emit, x, i, t) ->
            y = nyquistSampler x, t
            x = nyquistX x
            emit x, y
        .line
          width: 2
          color: 0x3090FF
          zBias: 20

        .interval
          length: WIDTH
          channels: 2
          expr: (emit, x, i, t) ->
            y = nyquistSampler x, t
            x = nyquistX x
            emit x, y
        .point
          size: 5
          color: 0xFFFFFF
          zBias: 21
          zIndex: 1
          zOrder: -5
        .point
          size: 4
          color: 0x3090FF
          zBias: 22
          zIndex: 1
          zOrder: -6

        .area
          width:  3
          height: 16
        .interval
          length: WIDTH * 32
          minFilter: 'linear'
          magFilter: 'linear'
          expr: (emit, x, i, t) ->
            x = nyquistXi x
            y = nyquistSampler x, t
            emit y, y, y, 1
        .surface
          color: 0xffffff
          points: '<<'
          map: '<'
          zBias: -5

        .slide
            steps: 0
            from: 6
            to: 8
          .reveal
              duration: 3
              delayEnter: 1
              delayExit:  .5
              stagger: [0, -5]
            .transform
                position: [0, 1, -10000]
                rotation: [π / 2, 0, 0]
                scale: [1, 10000, 1]
              .area
                width:  3
                height: 128
                rangeX: [-WIDTH*3, WIDTH*4]
              .interval
                range: [-WIDTH*3, WIDTH*4]
                length: WIDTH * 64
                minFilter: 'linear'
                magFilter: 'linear'
                expr: (emit, x, i, t) ->
                  x = nyquistXi x
                  y = nyquistSampler x, t
                  emit y, y, y, 1
              .surface
                color: 0xffffff
                points: '<<'
                map: '<'
                zBias: -5
            .end()
          .end()
        .end()

        .transform
            rotation: [π / 2, 0, 0]
            scale: [1, HEIGHT, 1]
          .area
            width:  3
            height: 3
          .interval
            length: WIDTH
            expr: (emit, x, i, t) ->
              y = nyquistSampler x, t
              emit y, y, y, 1
          .surface
            color: 0xffffff
            points: '<<'
            map: '<'
            zBias: 1

nyquistShader = mathbox.select('#nyquistShader')[0]

# ====================================================================================

triangleFace1 =
  pixelGrid
  .slide
      steps: 0
      from: 28
      to: 31
    .reveal
        duration: 1
      .array
        channels: 3
        length: 3
        expr: triangleRel
      .transpose
        order: 'yzwx'
      .transform
          position: [14, 10, 1]
          scale: [10, 10]
        .step
          duration: 1
          trigger: 2
          script: [
            [{rotation: [0, 0, 0]}]
            [{rotation: [0, .4, 0]}]
          ]
        .face
          color: deepred
          zBias: 5

triangleFace2 =
  pixelGrid
  .slide
      steps: 0
      from: 28
      to: 31
    .reveal
        duration: 1
      .array
        channels: 3
        length: 3
        expr: triangleRel
      .transpose
        order: 'yzwx'
      .transform
          position: [18, 10, -1]
          scale: [10, 10]
        .step
          duration: 1
          trigger: 2
          script: [
            [{rotation: [0, 0, 0]}]
            [{}, {rotation: (t) -> [0, Math.cos(t), 0]}]
          ]
        .face
          color: blue
          zBias: 5

# ====================================================================================

triangleFaceDepth1 =
  pixelGridDepth
  .slide
      steps: 0
      from: 29
      to: 31
    .reveal
        delayEnter: 1
        duration: 1

      .vertex
          pass: 'eye'
          shader: depthVertex

        .fragment
            shader: depthFragment


          .array
            channels: 3
            length: 3
            expr: triangleRel
          .transpose
            order: 'yzwx'
          .transform
              position: [14, 10, 1]
              scale: [10, 10]
            .step
              duration: 1
              script: [
                [{rotation: [0, 0, 0]}]
                [{rotation: [0, .4, 0]}]
              ]
            .face
              color: deepred
              zBias: 5

triangleFaceDepth2 =
  pixelGridDepth
  .slide
      steps: 0
      from: 29
      to: 31
    .reveal
        delayEnter: 1
        duration: 1

      .vertex
          pass: 'eye'
          shader: depthVertex

        .fragment
            shader: depthFragment

          .array
            channels: 3
            length: 3
            expr: triangleRel
          .transpose
            order: 'yzwx'
          .transform
              position: [18, 10, -1]
              scale: [10, 10]
            .step
              duration: 1
              script: [
                [{rotation: [0, 0, 0]}]
                [{}, {rotation: (t) -> [0, Math.cos(t), 0]}]
              ]
            .face
              color: blue
              zBias: 5

# ====================================================================================

pixelCanvasDepth =
  pixelView
  .slide
      steps: 0
      from: 29
      to: 31
    .reveal
        stagger: [5]
        duration: 1
        delay: 1
      .area
        width:  WIDTH  * 2 + 1
        height: HEIGHT * 2 + 1
        expr: (emit, x, y, i, j) ->
          di = i % 2
          dj = j % 2

          emit x + .499 * di, y + .499 * dj, 0
      .shader
        sources: pixelRTTDepth
        code: """
        uniform float width;
        uniform float height;
        vec4 getColorSample(vec4 xyzw);
        vec4 getPositionSample(vec4 xyzw);
        vec4 getSample(vec4 xyzw) {
          vec4 pos = getPositionSample(xyzw);
          xyzw = (xyzw - mod(xyzw, 2.0)) / 2.0;
          vec4 rgba = getColorSample(xyzw);
          return vec4(pos.xy, 16.0 * (1.0 - rgba.r), 0.0);
        }
        """
        width:  WIDTH
        height: HEIGHT
      .resample()
      .surface
        color: 0xFFFFFF
        map: pixelRTT
        zBias: 15
      .surface
        color: 0x000000
        lineX: true
        lineY: true
        fill: false
        zBias: 17

# ====================================================================================

present
  .slide
      steps: 0
      from: 32
      to: 33
    .reveal
        stagger: [2, 2]
        delayEnter: 2
      .cartesian(
        {}, {rotation: (t) -> [0, t, 0]}
      )
        .area
          width:  2
          height: 2
        .transform
            position: [0, 0, .2]
          .surface
            color: blue
            opacity: .5
          .end()
        .transform
            position: [0, 0, 0]
          .surface
            color: 0
            opacity: .5
          .end()
        .transform
            position: [0, 0, -.2]
          .surface
            color: red
            opacity: .5
          .end()

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
