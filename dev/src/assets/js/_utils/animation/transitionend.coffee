#
# transitionend
#

module.exports = (namescape = '')->
  if namescape
    return "transitionend.#{namescape} webkitTransitionEnd.#{namescape} mozTransitionEnd.#{namescape} oTransitionEnd.#{namescape}"
  else
    return 'transitionend webkitTransitionEnd mozTransitionEnd oTransitionEnd'
