utils = require '../_utils/utils'
TakumiGeometry = require './TakumiGeometry'

class TakumiObject3D extends THREE.Object3D
  _NUM_ANIMATIONS = 6
  _TTL_LABELS = [ 'about', 'blog', 'bookmarks', 'works' ]

  constructor: ->
    super()

    @geometry = new TakumiGeometry 0.4
    @material = new THREE.RawShaderMaterial
      vertexShader: require './_glsl/takumi.vert'
      fragmentShader: require './_glsl/takumi.frag'
      transparent: true
      uniforms:
        time: { type: '1f', value: 0 }
        ttlScale: { type: '1f', value: 1 }
        animationParam1: { type: '1f', value: 0 }
        animationParam2: { type: '1f', value: 0 }
        animationParam3: { type: '1f', value: 0 }
        animationParam4: { type: '1f', value: 0 }
        animationParam5: { type: '1f', value: 0 }
        animationParam6: { type: '1f', value: 0 }
        animationParamTtlAbout: { type: '1f', value: 0 }
        animationParamTtlBlog: { type: '1f', value: 0 }
        animationParamTtlBookmarks: { type: '1f', value: 0 }
        animationParamTtlWorks: { type: '1f', value: 0 }

    @takumiMesh = new THREE.Mesh @geometry, @material

    @animationNoArr = []
    @currentAnimationNo = @getNextAnimationNo()
    @material.uniforms["animationParam#{@currentAnimationNo}"].value = 1

    @add @takumiMesh


  setTtlScale: (width, height)->
    if width / height > 1
      # 横長
      ttlScale = width / 20000
    else
      # 縦長
      ttlScale = height / 20000

    # if utils.isMobile then ttlScale *= 2
    @material.uniforms.ttlScale.value = ttlScale
    return


  update: ->
    @material.uniforms.time.value += 0.001
    return


  backToAnimation1: ->
    @animate @currentAnimationNo, 0
    @animate 1, 1
    @currentAnimationNo = 1
    return


  animateTo: (animationNo)->
    @currentAnimationNo = animationNo
    @animate 1, 0
    @animate @currentAnimationNo, 1
    return


  animateToTtl: (name)->
    for i in [1.._NUM_ANIMATIONS]
      @animate i, 0, 2

    for ttl in _TTL_LABELS
      param = if ttl is name then 1 else 0
      @animate "Ttl#{utils.capitalize(ttl)}", param, 2

    return


  animateFromTtl: ->
    @animate @currentAnimationNo, 1, 2

    for ttl in _TTL_LABELS
      @animate "Ttl#{utils.capitalize(ttl)}", 0, 2

    return


  toggleAnimation: ->
    if @currentAnimationNo is 1
      return @animateTo @getNextAnimationNo()
    else
      @backToAnimation1()
    return


  getNextAnimationNo: ->
    if @animationNoArr.length is 0
      @animationNoArr = _.chain(_.range 2, _NUM_ANIMATIONS + 1).shuffle().value()
    return @animationNoArr.shift()


  animate: (animationSuffix, value, duration = 3)->
    animationSuffix = animationSuffix.toString()
    return TweenMax.to @material.uniforms["animationParam#{animationSuffix}"], duration, { overwrite: true, value: value, ease: Linear.easeNone }


  addAttributeFromImgData: (name, points)->
    return @geometry.addAttributeFromImgData name, points


module.exports = TakumiObject3D
