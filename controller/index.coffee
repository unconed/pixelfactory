makeSlideshow = require './slideshow'
makeControls  = require './controls'

root = if typeof module != 'undefined' then module else null
root = if typeof window != 'undefined' then window else root

root.App =
  mount: (_slides, _controls, location) ->

    getIndex = ()  -> +(location.hash.split('#')[1] || '0');
    setIndex = (i) -> location.hash = '#' + i

    slideshow = makeSlideshow _slides,   getIndex(), setIndex
    controls  = makeControls  _controls, slideshow

    root.onhashchange = () -> slideshow.go getIndex()

    setTimeout () -> document.body.classList.add 'animate'
