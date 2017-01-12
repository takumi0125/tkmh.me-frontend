class tkmh.common.TakumiGeometry extends THREE.BufferGeometry
  _NUM_CUBES_DEPTH = 4

  constructor: (@cubeWidth = 1)->
    super()

    @cubeWidthHalf = @cubeWidth / 2

    # takumi logo
    # left block cols 7
    # right block cols 9
    # margin 1
    # rows 22
    #
    # block1 = 7 * 3
    # block2 = 3 * 14
    # block3 = 7 * 3
    # block4 = 9 * 3
    # block5 = 3 * 3
    # block6 = 7 * 3
    # block7 = 3 * 6
    # block8 = 9 * 3
    @takumiWidth = (7 + 9 + 1) * @cubeWidth
    @takumiHeight = 22 * @cubeWidth
    @takumiDepth = _NUM_CUBES_DEPTH * @cubeWidth

    @takumiWidthHalf = @takumiWidth / 2
    @takumiHeightHalf = @takumiHeight / 2
    @takumiDepthHalf = @takumiDepth / 2


    # init vertices and attributes
    @vertices = []
    @vertexIndices = []
    @cubeCenters = []
    @cubeRandoms = []
    @triangleRandoms = []
    @triangleCenters = []
    @noiseValues = []

    # block1
    for w in [0...7]
      for h in [0...3]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block 2
    for w in [0...3]
      for h in [0...14]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf + 2 * @cubeWidth
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf - 4 * @cubeWidth
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block3
    for w in [0...7]
      for h in [0...3]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf - (22 - 3) * @cubeWidth
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block4
    for w in [0...9]
      for h in [0...3]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf + 8 * @cubeWidth
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block5
    for w in [0...3]
      for h in [0...3]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf + 10 * @cubeWidth
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf - 4 * @cubeWidth
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block6
    for w in [0...7]
      for h in [0...3]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf + 10 * @cubeWidth
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf - 8 * @cubeWidth
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block7
    for w in [0...3]
      for h in [0...6]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf + 14 * @cubeWidth
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf - 12 * @cubeWidth
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # block8
    for w in [0...9]
      for h in [0...3]
        for d in [0..._NUM_CUBES_DEPTH]
          @addCubeVertices(
            w *  @cubeWidth - @takumiWidthHalf + @cubeWidthHalf + 8 * @cubeWidth
            h * -@cubeWidth + @takumiHeightHalf - @cubeWidthHalf - (22 - 3) * @cubeWidth
            d * -@cubeWidth + @takumiDepthHalf - @cubeWidthHalf
          )

    # attributes
    @addAttribute 'position', new THREE.BufferAttribute(new Float32Array(@vertices), 3)
    @addAttribute 'vertexIndex', new THREE.BufferAttribute(new Uint16Array(@vertexIndices), 1)
    @addAttribute 'cubeCenter', new THREE.BufferAttribute(new Float32Array(@cubeCenters), 3)
    @addAttribute 'cubeRandom', new THREE.BufferAttribute(new Float32Array(@cubeRandoms), 3)
    @addAttribute 'triangleCenter', new THREE.BufferAttribute(new Float32Array(@triangleCenters), 3)
    @addAttribute 'triangleRandom', new THREE.BufferAttribute(new Float32Array(@triangleRandoms), 3)
    @addAttribute 'noiseValue', new THREE.BufferAttribute(new Float32Array(@noiseValues), 1)

    @computeVertexNormals()

    # 配列としては使用しないので、メモリ解放
    delete @vertices
    delete @cubeCenters
    delete @vertexIndices
    delete @cubeRandoms
    delete @triangleRandoms
    delete @noiseValues



  addAttributeFromImgData: (name, points)->
    numTriangles = @attributes.vertexIndex.count / 3
    if numTriangles > points.length
      points = points.concat points
    points = _.sample points, numTriangles

    attr = []
    for point in points
      for i in [0...3]
        attr.push point.x
        attr.push point.y

    @addAttribute "#{name}Pos", new THREE.BufferAttribute(new Float32Array(attr), 2)
    attr = null
    return



  addCubeVertices: (offsetX = 0, offsetY = 0, offsetZ = 0)->
    geometry = new THREE.BufferGeometry()

    @cubeWidthHalf = @cubeWidth / 2
    cubeVertices = [
      # front
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ

       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ

      # back
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ

       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ

      # top
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ

       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ

      # bottom
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ

       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ

       # left
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ

      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
      -@cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ

      # right
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ

       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX, -@cubeWidthHalf + offsetY,  @cubeWidthHalf + offsetZ
       @cubeWidthHalf + offsetX,  @cubeWidthHalf + offsetY, -@cubeWidthHalf + offsetZ
    ]

    cubeRandom = [ @getRandomValue(), @getRandomValue(), @getRandomValue()  ]
    for i in [0...36]
      # 頂点のインデックス
      @vertexIndices.push @vertexIndices.length

      # cube用のランダム値 (x, y, z)
      @cubeRandoms.push cubeRandom[0]
      @cubeRandoms.push cubeRandom[1]
      @cubeRandoms.push cubeRandom[2]

      # cubeの中心座標 (x, y, z)
      @cubeCenters.push offsetX
      @cubeCenters.push offsetY
      @cubeCenters.push offsetZ

      vertex = new THREE.Vector3 cubeVertices[i * 3], cubeVertices[i * 3 + 1], cubeVertices[i * 3 + 2]
      vertex.normalize()
      @noiseValues.push PerlinNoise.noise(vertex.x, vertex.y, vertex.z)

      if i % 3 is 0
        triangleRandomBaseValue = [ Math.random(), Math.random(), Math.random() ]
        triangleCenter = [
          (cubeVertices[i * 3] + cubeVertices[i * 3 + 3] + cubeVertices[i * 3 + 6]) / 3
          (cubeVertices[i * 3 + 1] + cubeVertices[i * 3 + 1 + 3] + cubeVertices[i * 3 + 1 + 6]) / 3
          (cubeVertices[i * 3 + 2] + cubeVertices[i * 3 + 2 + 3] + cubeVertices[i * 3 + 2 + 6]) / 3
        ]

      # triangleのランダム値 (x, y, z)
      @triangleRandoms.push @getRandomValue2(triangleRandomBaseValue[0], 0.01)
      @triangleRandoms.push @getRandomValue2(triangleRandomBaseValue[1], 0.01)
      @triangleRandoms.push @getRandomValue2(triangleRandomBaseValue[2], 0.01)

      @triangleCenters.push triangleCenter[0]
      @triangleCenters.push triangleCenter[1]
      @triangleCenters.push triangleCenter[2]


    Array.prototype.push.apply @vertices, cubeVertices


  # -1 から 1までのランダムな値を取得
  getRandomValue: ->
    return utils.map Math.random(), 0, 1, -1, 1


  getRandomValue2: (baseValue, addValue)->
    return utils.map baseValue - Math.random() * addValue, 0, 1, -1, 1
