{difference, flatten, unique} = require 'lodash'

IFRAME_UNLOAD = 150

slideshow = (el, index, callback) ->
  steps  = process fetch el, '.slide'
  embeds = sources el, 'iframe[data-src], video[data-src], img[data-src]'
  last   = []
  open   = []

  reset el for el in step for step in steps

  trigger clicker(steps.length, index), (i, delta) ->
    inactive = last
    active   = last = steps[i]

    return if inactive == active

    loaded   = flatten (show el, i, delta for el in difference active, inactive)
    unloaded = flatten (hide el, i, delta for el in difference inactive, active)

    open = difference unique(open.concat(loaded).filter (x) -> x?), unloaded
    open.map (el) -> notify el, i, delta

    callback i, delta

clicker = (n, i = 0) ->
  set  = (j, delta) -> [i = j, delta]
  go   = (j) -> set (j + n) % n, j - i
  step = (d) -> go i + d
  next = ()  -> step 1
  prev = ()  -> step -1
  get  = ()  -> i

  {go, step, next, prev, length: n, get}

trigger = (clicker, render) ->
  out = {}
  for k, f of clicker
    out[k] =
      if k in ['go', 'step', 'next', 'prev']
        do (f) -> () -> render.apply this, f.apply this, arguments
      else
        f

  out.step 0
  out

notify = (el, i, delta) ->
  i -= el.slideIndex
  el.contentWindow?.postMessage {type: 'slideshow', i, delta}, '*'

show = (el, i, delta) ->
  back = delta < 0
  prep el, back
  setTimeout () -> release el, true
  el.sources?.map (el) ->
    prep el, back
    clearTimeout el.timer if el.timer?
    el.onload = () ->
      notify el, i, delta
      release el, true
    el.src = el.dataset.src
    el

hide = (el, i, delta) ->
  back = delta >= 0
  prep el, back
  setTimeout () -> release el, false
  el.sources?.map (el) ->
    prep el, back
    el.onload = null
    setTimeout () -> release el, false
    el.timer = setTimeout (() -> el.src = 'about:blank'), IFRAME_UNLOAD
    el

prep = (el, back) ->
  el.classList.remove 'animate'
  el.classList.toggle 'slide-out', back
  el.classList.toggle 'slide-in', !back

release = (el, active) ->
  el.classList.toggle 'slide-active', active
  el.classList.add 'animate'

reset = (el) -> el.classList.remove 'slide-active'

fetch   = (el, selector)-> el.querySelectorAll selector
process = (els) -> step.concat builds(step), holds(step) for step in collapse slides els

slides   = (els) ->     tag filter(parents(el),        '.slide'), i for el, i in els
builds   = (els) -> flatten(filter prevs(el).slice(1), '.build'     for el    in els)
holds    = (els) ->
  list = []
  for el in els
    hold = (prev for prev, i in prevs(el) when match prev, ".stay-#{i + 1}")
    list.push hold
  flatten list

tag      = (els, i) ->
  els.map (el) ->
    if !el.slideIndex?
      el.slideIndex = i
      el.classList.add "slide-#{i}"
  els
collapse = (slides) ->
  list = []
  for els in slides
    if match els[0], '.instant'
      list[list.length - 1].push els[0]
    else
      list.push els
  list

sources = (el, selector) ->
  for source in fetch el, selector
    slide = filter(parents(source), '.slide')[0]
    slide.sources ?= []
    slide.sources.push source
    source.slideIndex = slide.slideIndex

traverse = (key) -> (el) -> ref while el and ([el, ref] = [el[key], el])
prevs    = traverse 'previousElementSibling'
parents  = traverse 'parentNode'

filter  = (els, sel) -> els.filter (el) -> match el, sel
match   = (el, sel)  -> patch(el) and el.matchesSelector sel
patch   = (el)  -> el.matchesSelector ?= el.webkitMatchesSelector ? el.mozMatchesSelector

module.exports = slideshow
