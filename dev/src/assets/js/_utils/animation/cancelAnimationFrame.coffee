#
# cancelAnimationFrame wrapper
#

window.cancelAnimationFrame = (=>
  return  window.cancelAnimationFrame ||
          window.mozCancelAnimationFrame ||
          (id)=> return clearTimeout(id)
  )()
