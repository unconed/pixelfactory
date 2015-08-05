controls = (els, slideshow) ->

  prev = els.querySelector '.prev'
  next = els.querySelector '.next'

  prev.onclick = slideshow.prev
  next.onclick = slideshow.next

module.exports = controls