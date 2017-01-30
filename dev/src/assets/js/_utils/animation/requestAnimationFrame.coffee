#
# requestAnimationFrame wrapper
#

window.requestAnimationFrame = (=>
  return  window.requestAnimationFrame ||
          window.mozRequestAnimationFrame ||
          window.webkitRequestAnimationFrame ||
          window.msRequestAnimationFrame ||
          (callback)=> return setTimeout(callback, 1000 / 30)
  )()
