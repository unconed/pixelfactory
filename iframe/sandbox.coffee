window.mathbox =
{mathbox, three} = mathBox
  plugins: ['core', 'mathbox', 'controls', 'cursor']
  controls:
    klass: THREE.OrbitControls
  camera:
    fov: 60

document.body.classList.add 'sandbox'
mathbox.set scale: 720, focus: 3

three.renderer.setClearColor new THREE.Color(0xFFFFFF), 1
three.camera.position.set 0, 0, 3

types =
  for k, klass of MathBox.Primitives.Types.Classes
    suffix = if klass.model == MathBox.Model.Group then ' /' else ''
    "<#{k}#{suffix}>"

types.sort()

console.info "MathBox Sandbox - Use `mathbox.inspect()` to see the tree, `view = view.tag()` to spawn a `<tag>` inside another one, starting with `mathbox`."
console.log "Available: " + types.join "  "
