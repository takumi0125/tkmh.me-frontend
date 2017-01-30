#
# preloadImg
#

module.exports = (imgPath)->
  return new Promise (resolve)->
    img = new Image()
    img.addEventListener 'load', (e)->
      img.removeEventListener 'load', arguments.callee
      return resolve()
    img.src = imgPath
