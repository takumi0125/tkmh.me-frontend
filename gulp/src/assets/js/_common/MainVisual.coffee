class tkmh.common.MainVisual
  _BUFFER_CAM_DISTANCE = 20
  _PLANE_SIZE = 100

  _TTL_IMG_PATHS =
    about    : '/assets/img/headerTtlAbout.png'
    blog     : '/assets/img/headerTtlBlog.png'
    bookmarks: '/assets/img/headerTtlBookmarks.png'
    works    : '/assets/img/headerTtlWorks.png'


  constructor: ->
    @$container = $ '#mainVisual'
    @$canvas = @$container.find 'canvas'

    @width = 100
    @height = 100

    @isWebGLSupported = false

    @sensorAxisDir = -1
    if utils.isiPhone or utils.isiPad
      @sensorAxisDir = 1


  init: (callback)->
    # check if webGL is available
    if Detector.webgl
      # supported
      @initWebGL callback
    else
      # not supported
      log 'not supported'
      callback?()



  # webGL initalization
  initWebGL: (callback)->
    @isWebGLSupported = true

    # three.js basic

    # webGL renderer
    @renderer = new THREE.WebGLRenderer
      canvas: @$canvas.get 0
      alpha: true
      antialias: true

    # 高解像度対応
    pixelRatio = Math.min(window.devicePixelRatio or 1, 2)
    @renderer.setPixelRatio pixelRatio

    # scene
    @bufferScene = new THREE.Scene()

    # bufferCamera
    @bufferCamera = new THREE.PerspectiveCamera 45, @width / @height, 1, 1000
    @bufferCamera.position.set 0, 0, _BUFFER_CAM_DISTANCE
    @bufferScene.add @bufferCamera

    @bufferCameraDefaultPos = @bufferCamera.position.clone()
    @bufferCameraMatrix = new THREE.Matrix4()

    # 3Dオブジェクト
    @takumiObject3D = new tkmh.common.TakumiObject3D()
    @takumiObject3D.setTtlScale @width, @height
    @bufferScene.add @takumiObject3D

    if device.desktop()
      @initFullVersion()
    else
      @initSimpleVersion()
    # @initFullVersion()


    # タイトル用画像を読み込み
    $.when(
      @initTtlImg 'about'
      @initTtlImg 'blog'
      @initTtlImg 'bookmarks'
      @initTtlImg 'works'
    ).then -> callback?()

    return


  # タイトル画像をイニシャライズ
  initTtlImg: (name)->
    d = $.Deferred()

    imgPath = _TTL_IMG_PATHS[name]

    $img = $('<img>').one 'load', (e)=>
      img = $img.get 0
      canvas = document.createElement 'canvas'
      context = canvas.getContext '2d'
      canvas.width = img.width
      canvas.height = img.height
      context.drawImage img, 0, 0, img.width, img.height
      imgData = context.getImageData 0, 0, img.width, img.height

      points = []
      for i in [0...imgData.data.length - 1] by 4
        alpha = imgData.data[i + 3]
        index = i / 4
        if alpha > 0
          points.push {
            x: index % img.width - img.width / 2
            y: img.height / 2 - Math.floor(index / img.width)
          }

      @takumiObject3D.addAttributeFromImgData name, points

      d.resolve()

    .attr 'src', imgPath

    return d.promise()


  # タイトルの形に
  animateToTtl: (name)->
    @clearToggleAnimationTimer()
    @takumiObject3D.animateToTtl name

    if @mainMesh?
      TweenMax.to @mainMesh.material.uniforms.noiseCoefficient, 1.0, {
        overwrite: true
        value: 10
        ease: Expo.easeOut
        delay: 1
      }


  # タイトルの形から復帰
  animateFromTtl: ->
    @setToggleAnimationTimer()
    @takumiObject3D.animateFromTtl()

    if @mainMesh?
      TweenMax.to @mainMesh.material.uniforms.noiseCoefficient, 2.0, {
        overwrite: true
        value: 0
        ease: Expo.easeOut
      }


  # アニメーション切り替えタイマーをセット
  setToggleAnimationTimer: ->
    @toggleAnimationTimerId = setInterval (=> @takumiObject3D.toggleAnimation()), 10000


  # アニメーション切り替えタイマーを消去
  clearToggleAnimationTimer: ->
    clearTimeout @toggleAnimationTimerId


  initFullVersion: ->
    # buffer
    @buffer = new THREE.WebGLRenderTarget(
      @width
      @height
      {
        magFilter: THREE.NearestFilter
        minFilter: THREE.NearestFilter
        wrapS: THREE.ClampToEdgeWrapping
        wrapT: THREE.ClampToEdgeWrapping
      }
    )

    @scene = new THREE.Scene()
    @camera = new THREE.OrthographicCamera -@textureWidth / 2, @textureWidth / 2, @textureHeight / 2, -@textureHeight / 2, -10, 10
    @camera.target = new THREE.Vector3 0, 0, 0
    @camera.position.z = 10
    @mainMesh = new THREE.Mesh(
      new THREE.PlaneGeometry _PLANE_SIZE, _PLANE_SIZE
      new THREE.RawShaderMaterial tkmh.shader.PostProcessShader
    )
    @mainMesh.material.uniforms.texture.value = @buffer.texture
    @mainMesh.material.uniforms.resolution.value = new THREE.Vector2 @width, @height
    @resizeMainMesh()
    @scene.add @mainMesh

    @noiseCoefficient = 0
    @mainMesh.material.uniforms.noiseCoefficient.value = @noiseCoefficient

    # #
    # # dat.gui
    # #
    # gui = new dat.GUI()
    # gui.add(@, 'noiseCoefficient', 0, 10.0).onChange =>
    #   @mainMesh.material.uniforms.noiseCoefficient.value = @noiseCoefficient
    # $('.dg.ac').css 'z-index', 1000


  initSimpleVersion: ->
    @draw = @draw2
    @resize = @resize2


  # 描画
  draw: =>
    @takumiObject3D.update()
    @mainMesh.material.uniforms.time.value += 0.001
    @renderer.render @bufferScene, @bufferCamera, @buffer
    @renderer.render @scene, @camera
    return


  draw2: =>
    @takumiObject3D.update()
    @renderer.render @bufferScene, @bufferCamera


  # resize main mesh
  resizeMainMesh: =>
    @mainMesh.scale.set(
      @width / _PLANE_SIZE
      @height / _PLANE_SIZE
      1
    )
    return


  # resize
  resize: (@width, @height)=>
    # buffer
    @bufferCamera.aspect = @width / @height
    @bufferCamera.updateProjectionMatrix()
    @buffer.setSize @width, @height

    @takumiObject3D.setTtlScale @width, @height

    # main
    @resizeMainMesh()
    @mainMesh.material.uniforms.resolution.value.x = @width
    @mainMesh.material.uniforms.resolution.value.y = @height
    @camera.left = -@width / 2
    @camera.right = @width / 2
    @camera.top = @height / 2
    @camera.bottom = -@height / 2
    @camera.updateProjectionMatrix()
    @renderer.setSize @width, @height
    return


  # resize2
  resize2: (@width, @height)=>
    @bufferCamera.aspect = @width / @height
    @bufferCamera.updateProjectionMatrix()
    @renderer.setSize @width, @height
    @takumiObject3D.setTtlScale @width, @height
    return


  # window mosue move handler
  windowMouseMoveHandler: (e)=>
    dx = utils.map e.pageX / @width, 0, 1, -1, 1
    dy = utils.map e.pageY / @height, 0, 1, -1, 1
    @setBufferCameraPos dx, dy


    @isMoved = true
    return


  # device motion handler
  deviceMotionHandler: (e)=>
    dx = e.originalEvent.accelerationIncludingGravity.x / 4
    dy = e.originalEvent.accelerationIncludingGravity.y / 4
    @setBufferCameraPos dx * @sensorAxisDir, dy * @sensorAxisDir
    return


  # カメラの位置をセット
  setBufferCameraPos: (dx, dy)->
    pos = @bufferCameraDefaultPos.clone()
    @bufferCameraMatrix.identity()
    @bufferCameraMatrix.makeRotationX dy * Math.PI / 6
    pos.applyMatrix4 @bufferCameraMatrix
    @bufferCameraMatrix.makeRotationY dx * Math.PI / 6
    pos.applyMatrix4 @bufferCameraMatrix

    TweenMax.to @bufferCamera.position, 3.0, {
      overwrite: true
      x: pos.x
      y: pos.y
      z: pos.z
      ease: Expo.easeOut
      onUpdate: => @bufferCamera.lookAt new THREE.Vector3()
    }
    return
