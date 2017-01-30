#
# module exports
#

module.exports =
  # img
  preloadImg: require './img/preloadImg'

  # sns
  # setUpBtnTwitter : require './sns/setUpBtnTwitter'
  # setUpBtnLine    : require './sns/setUpBtnLine'
  # setUpBtnFacebook: require './sns/setUpBtnFacebook'

  # animation
  transitionend: require './animation/transitionend'

  # array
  # shuffleArr: require './array/shuffleArr'

  # math
  map: require './math/map'

  # string
  capitalize: require './string/capitalize'
  # pad       : require './string/pad'

  # user agent
  isFirefox        : require './ua/isFirefox'

  # isIE8            : require './ua/isIE8'
  # isIE9            : require './ua/isIE9'
  # isIE10           : require './ua/isIE10'
  isIE11           : require './ua/isIE11'
  isEdge           : require './ua/isEdge'

  isiPad           : require './ua/isiPad'
  isiPhone         : require './ua/isiPhone'

  isAndroid        : require './ua/isAndroid'

  # getiOSVersion    : require './ua/getAndroidVersion'
  # getAndroidVersion: require './ua/getAndroidVersion'

#
# defined in window object
#

# log
require './log/log'

# animation
require './animation/requestAnimationFrame'
require './animation/cancelAnimationFrame'

# AudioContext
# require './audio/AudioContext'
