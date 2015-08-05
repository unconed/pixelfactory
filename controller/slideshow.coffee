{difference, flatten} = require 'lodash'

slideshow = (el, index, callback) ->
  steps = process fetch el
  last  = []

  reset el for el in step for step in steps

  trigger clicker(steps.length, index), (i, delta) ->
    inactive = last
    active   = last = steps[i]

    return if inactive == active

    back = delta < 0
    show el, back for el in difference active, inactive
    hide el, back for el in difference inactive, active

    callback i, delta

prep = (el, back) ->
  el.classList.remove 'animate'
  el.classList.toggle 'slide-out', back
  el.classList.toggle 'slide-in', !back

release = (el, active) ->
  el.classList.toggle 'slide-active', active
  el.classList.add 'animate'

reset = (el) -> el.classList.remove 'slide-active'

show = (el, back) ->
  prep el, back
  setTimeout () -> release el, true

hide = (el, back) ->
  prep el, !back
  setTimeout () -> release el, false

clicker = (n, i = 0) ->
  set  = (j, delta) -> [i = j, delta]
  go   = (j) -> set (j + n) % n, j - i
  step = (d) -> go i + d
  next = ()  -> step 1
  prev = ()  -> step -1

  {go, step, next, prev}

trigger = (clicker, render) ->
  out = {}
  for k, f of clicker
    out[k] = do (f) -> () -> render.apply this, f.apply this, arguments

  out.step 0
  out

fetch   = (el)  -> el.querySelectorAll '.slide'
process = (els) -> step.concat builds step for step in slides els

slides  = (els) ->         filter parents(el), '.slide' for el in els
builds  = (els) -> flatten(filter prevs(el),   '.build' for el in els)

traverse = (key) -> (el) -> ref while el and ([el, ref] = [el[key], el])
prevs    = traverse 'previousSibling'
parents  = traverse 'parentNode'

filter  = (els, sel) -> els.filter (el) -> patch(el) and el.matchesSelector sel
patch   = (el)  -> el.matchesSelector ?= el.webkitMatchesSelector ? el.mozMatchesSelector

module.exports = slideshow
