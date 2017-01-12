utils = window.utils || {}
window.utils = utils

ua = navigator.userAgent.toLowerCase()

utils.isAndroid = ua.indexOf('android') isnt -1

utils.isiPhone = ua.indexOf('iphone') isnt -1

utils.isiPad = ua.indexOf('ipad') isnt -1


utils.TRANSITION_END = 'transitionend webkitTransitionEnd mozTransitionEnd oTransitionEnd'


utils.preloadImg = (imgPath)->
  d = new $.Deferred()
  $('<img>').one 'load', (e)-> return d.resolve()
  .attr 'src', imgPath
  return d.promise()


utils.getiOSVersion = ->
  v = (navigator.appVersion).match /OS (\d+)_(\d+)_?(\d+)?/
  return [ parseInt(v[1], 10), parseInt(v[2], 10), parseInt(v[3] || 0, 10) ]


utils.getAndroidVersion = ->
  v = (navigator.appVersion).match /Android (\d+).(\d+).?(\d+)?;/
  return [ parseInt(v[1], 10), parseInt(v[2], 10), parseInt(v[3] || 0, 10) ]


# ゼロで埋める
utils.zeroPadding = (num, numDigits)->
  num = '' + num
  for i in [0...numDigits]
    num = '0' + num
  return num.slice -numDigits


# 頭文字を大文字に
utils.toCap = (txt)->
  return txt.charAt(0).toUpperCase() + txt.slice(1)


# windowをスクロール
# windowをスクロール
utils.windowScrollTween = null
utils.windowScrollTweenTimer = null
utils.windowScrollTo = (scrollTo, duration = 1)->
  d = $.Deferred()
  utils.windowScrollTween?.kill()
  if utils.windowScrollTweenTimer?
    clearTimeout utils.windowScrollTweenTimer
    utils.windowScrollTweenTimer = null
  utils.windowScrollTween = TweenMax.to window, duration, { scrollTo:{ y: scrollTo }, overwrite: true, ease: Expo.easeOut, onComplete: ->
    d.resolve()
  }
  utils.windowScrollTweenTimer = setTimeout (->
    utils.windowScrollTween.play()
  ), 200
  return d.promise()


# 範囲をマッピング
utils.map = (value, inputMin, inputMax, outputMin, outputMax, clamp = true)->
  if clamp is true
    if value < inputMin then return outputMin
    if value > inputMax then return outputMax

  p = (outputMax - outputMin) / (inputMax - inputMin)
  return ((value - inputMin) * p) + outputMin


# This is a port of Ken Perlin's Java code. The
# original Java code is at http://cs.nyu.edu/%7Eperlin/noise/.
# Note that in this version, a number from 0 to 1 is returned.
window.PerlinNoise = new (->
  fade = (t) ->
    t * t * t * (t * (t * 6 - 15) + 10)

  lerp = (t, a, b) ->
    a + t * (b - a)

  grad = (hash, x, y, z) ->
    h = hash & 15
    # CONVERT LO 4 BITS OF HASH CODE
    u = if h < 8 then x else y
    v = if h < 4 then y else if h == 12 or h == 14 then x else z
    (if (h & 1) == 0 then u else -u) + (if (h & 2) == 0 then v else -v)

  scale = (n) ->
    (1 + n) / 2

  @noise = (x, y = 0, z = 0) ->
    p = new Array(512)
    permutation = [
      151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37, 240,
      21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88,
      237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83,
      111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216,
      80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186,
      3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58,
      17, 182, 189, 28, 42, 223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172,
      9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242,
      193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 106,
      157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222, 114, 67, 29, 24, 72, 243, 141,
      128, 195, 78, 66, 215, 61, 156, 180
    ]
    i = 0
    while i < 256
      p[256 + i] = p[i] = permutation[i]
      i++
    X = Math.floor(x) & 255
    Y = Math.floor(y) & 255
    Z = Math.floor(z) & 255
    x -= Math.floor(x)
    # FIND RELATIVE X,Y,Z
    y -= Math.floor(y)
    # OF POINT IN CUBE.
    z -= Math.floor(z)
    u = fade(x)
    v = fade(y)
    w = fade(z)
    A = p[X] + Y
    AA = p[A] + Z
    AB = p[A + 1] + Z
    B = p[X + 1] + Y
    BA = p[B] + Z
    BB = p[B + 1] + Z
    # THE 8 CUBE CORNERS,
    scale lerp(w, lerp(v, lerp(u, grad(p[AA], x, y, z), grad(p[BA], x - 1, y, z)), lerp(u, grad(p[AB], x, y - 1, z), grad(p[BB], x - 1, y - 1, z))), lerp(v, lerp(u, grad(p[AA + 1], x, y, z - 1), grad(p[BA + 1], x - 1, y, z - 1)), lerp(u, grad(p[AB + 1], x, y - 1, z - 1), grad(p[BB + 1], x - 1, y - 1, z - 1))))

  return
)


# requestAnimationFrame wrapper
window.requestAnimationFrame = (=>
  return  window.requestAnimationFrame ||
          (callback)=> return setTimeout(callback, 1000 / 60)
  )()

# cancelAnimationFrame wrapper
window.cancelAnimationFrame = (=>
  return  window.cancelAnimationFrame ||
          (id)=> return clearTimeout(id)
  )()


# console.log wrapper
window.isEnabledlog = true
window.log = (->
  if window.isEnabledlog
    if window.console? and window.console.log.bind?
      return window.console.log.bind window.console
    else
      return window.alert
  else ->
)()

console.log = ->
console.info = ->
console.warn = ->
