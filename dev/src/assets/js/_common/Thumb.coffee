class Thumb
  _GEOMETRY_SIZE = 100

  constructor: (@$container, @widthSegments = 20, @heightSegments = 10)->
    @isWebGLSupported = false


  init: (callback)->
    # check if webGL is available
    if Detector.webgl
      # supported
      @initWebGL callback
    else
      # not supported
      log 'not supported'
      callback?()
    return


  # webGL initalization
  initWebGL: (callback)->
    @isWebGLSupported = true

    @width = @$container.outerWidth()
    @height = @$container.outerHeight()

    # webGL renderer
    @renderer = new THREE.WebGLRenderer
      alpha: true
      antialias: true
    @$container.get(0).appendChild @renderer.domElement

    # 高解像度対応
    pixelRatio = Math.min(window.devicePixelRatio or 1, 2)
    @renderer.setPixelRatio pixelRatio

    # scene
    @scene = new THREE.Scene()

    # camera
    @camera = new THREE.PerspectiveCamera 45, @width / @height, 1, 1000
    @camera.position.set 0, 0, 1
    @scene.add @camera

    numVertices = (@widthSegments + 1) * (@heightSegments + 1)
    noiseValues = []
    for i in [0...numVertices]
      noiseValues.push utils.map(Math.random(), 0, 1, -1, 1, true)

    @geometry = new THREE.PlaneBufferGeometry _GEOMETRY_SIZE, _GEOMETRY_SIZE, @widthSegments, @heightSegments
    @geometry.addAttribute 'vertexIndex', new THREE.BufferAttribute(new Uint16Array(_.range(numVertices)), 1)
    @geometry.addAttribute 'noiseValue', new THREE.BufferAttribute(new Float32Array(noiseValues), 1)

    noiseValues = null

    @material = new THREE.RawShaderMaterial
      vertexShader: require './_glsl/thumb.vert'
      fragmentShader: require './_glsl/thumb.frag'
      transparent: true
      side: THREE.DoubleSide
      uniforms:
        animationParam: { type: '1f', value: 0 }
        texture: { type: 't' }

    @mesh = new THREE.Mesh @geometry, @material
    @scene.add @mesh

    $img = @$container.find('img')
    imgPath = $img.attr 'src'
    @material.uniforms.texture.value = new THREE.TextureLoader().load imgPath, (texture)=>
      @resize()
      @draw()
      $img.remove()
      $img = null
      @$container.find('.detail').remove()


    @$container.on
      mouseover: =>
        TweenMax.to @material.uniforms.animationParam, 1.4, { value: 1, ease: Linear.easeNone, overwrite: true, onUpdate: =>
          @draw()
        }

      mouseout: =>
        TweenMax.to @material.uniforms.animationParam, 1.4, { value: 0, ease: Linear.easeNone, overwrite: true, onUpdate: =>
          @draw()
        }

    return


  # 描画
  draw: =>
    @renderer.render @scene, @camera
    return


  resizeMesh: ->
    @mesh.scale.set(
      @width / _GEOMETRY_SIZE
      @height / _GEOMETRY_SIZE
      1.0
    )
    return


  dispose: ->
    @$container.off 'mouseover'
    @$container.off 'mouseout'
    @geometry.dispose()
    @material.uniforms.texture.value.dispose()
    @material.dispose()
    @scene.remove @mesh
    @scene.remove @camera
    @renderer.dispose()
    return


  # resize
  resize: =>
    @width = @$container.outerWidth()
    @height = @$container.outerHeight()

    @camera.aspect = @width / @height
    @camera.updateProjectionMatrix()

    cameraZ = -(@height / 2) / Math.tan((@camera.fov * Math.PI / 180) / 2)
    @camera.position.set　0, 0, -cameraZ
    @resizeMesh()

    @renderer.setSize @width, @height
    return

module.exports = Thumb
