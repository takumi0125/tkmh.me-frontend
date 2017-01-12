class tkmh.common.TakumiObject3D extends THREE.Object3D
  _NUM_ANIMATIONS = 6
  _TTL_LABELS = [ 'about', 'blog', 'bookmarks', 'works' ]

  constructor: ->
    super()

    @geometry = new tkmh.common.TakumiGeometry 0.4
    @material = new THREE.RawShaderMaterial tkmh.shader.TakumiShader
    @takumiMesh = new THREE.Mesh @geometry, @material

    @animationNoArr = []
    @currentAnimationNo = @getNextAnimationNo()
    @material.uniforms["animationParam#{@currentAnimationNo}"].value = 1

    @add @takumiMesh


  setTtlScale: (width, height)->
    ttlScale = width / 1200 * 0.08
    if device.mobile() then ttlScale *= 2
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
      @animate "Ttl#{utils.toCap(ttl)}", param, 2

    return


  animateFromTtl: ->
    @animate @currentAnimationNo, 1, 2

    for ttl in _TTL_LABELS
      @animate "Ttl#{utils.toCap(ttl)}", 0, 2

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
