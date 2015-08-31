window.mathbox =
{mathbox, three} = mathBox
  plugins: ['core', 'mathbox', 'controls', 'cursor']
  controls:
    klass: THREE.OrbitControls

three.renderer.setClearColor new THREE.Color(0xFFFFFF), 1

types =
  for k, klass of MathBox.Primitives.Types.Classes
    suffix = if klass.model == MathBox.Model.Group then ' /' else ''
    "<#{k}#{suffix}>"

types.sort()

console.info "MathBox Sandbox - Use `mathbox.inspect()` to see the tree, `view = view.tag()` to spawn a `<tag>` inside another one, starting with `mathbox`."
console.log "Available: " + types.join "  "
