#
# フロントエンド開発用 汎用gulpテンプレート
# v3.0.0
#

# ---------------------------------------------------------
#  設定
# ---------------------------------------------------------

# ソースディレクトリ
SRC_DIR = './src'

# 納品ディレクトリ
PUBLISH_DIR = '../htdocs'

# タスクから除外するためのプレフィックス
EXCRUSION_PREFIX = '_'

# ライブラリを格納するディレクトリ名
LIBRARY_DIR_NAME = 'lib'

# autoprefixerのオプション
AUTOPREFIXER_OPT = [ 'last 2 versions', 'ie 8', 'ie 9', 'Android 4', 'iOS 8' ]

# jadeで読み込むjson
DATA_JSON = "#{SRC_DIR}/#{EXCRUSION_PREFIX}data.json"

# assetsディレクトリへドキュメントルートからの相対パス
ASSETS_DIR = 'assets'

# clean対象のディレクトリ (除外したいパスがある場合にnode-globのシンタックスで指定)
CLEAN_DIR = [ "#{PUBLISH_DIR}/**/*" ]

# 各種パス
paths =
  html    : "#{SRC_DIR}/**/*.html"
  jade    : "#{SRC_DIR}/**/*.jade"
  css     : "#{SRC_DIR}/**/*.css"
  sass    : "#{SRC_DIR}/**/*.{sass,scss}"
  js      : "#{SRC_DIR}/**/*.js"
  json    : "#{SRC_DIR}/**/*.json"
  coffee  : "#{SRC_DIR}/**/*.coffee"
  cson    : "#{SRC_DIR}/**/*.cson"
  img     : [ "#{SRC_DIR}/**/img/**" ]
  others  : [
    "#{SRC_DIR}/**/*"
    "#{SRC_DIR}/**/.htaccess"
    "!#{SRC_DIR}/**/*.{html,jade,css,sass,scss,js,json,coffee,cson,md}"
    "!#{SRC_DIR}/**/img/**"
  ]
  jadeInclude: [
    "#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*/**/*.jade"
    "#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*.jade"
  ]
  sassInclude: [
    "#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*/**/*.{sass,scss}"
    "#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*.{sass,scss}"
  ]
  coffeeInclude: [
    "#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*/**/*.coffee"
    "#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*.coffee"
  ]


# ---------------------------------------------------------
#  各種モジュール
# ---------------------------------------------------------

# gulp関連
gulp         = require 'gulp'
autoprefixer = require 'gulp-autoprefixer'
changed      = require 'gulp-changed'
coffee       = require 'gulp-coffee'
coffeelint   = require 'gulp-coffeelint'
concat       = require 'gulp-concat'
data         = require 'gulp-data'
debug        = require 'gulp-debug'
filter       = require 'gulp-filter'
imagemin     = require 'gulp-imagemin'
jade         = require 'gulp-jade'
jsonlint     = require 'gulp-jsonlint'
notify       = require 'gulp-notify'
plumber      = require 'gulp-plumber'
sass         = require 'gulp-sass'
sprite       = require 'gulp.spritesmith'
uglify       = require 'gulp-uglify'
util         = require 'gulp-util'
webserver    = require 'gulp-webserver'

# その他モジュール
bower        = require 'main-bower-files'
browserify   = require 'browserify'
buffer       = require 'vinyl-buffer'
connectSSI   = require 'connect-ssi'
del          = require 'del'
exec         = require('child_process').exec
mergeStream  = require 'merge-stream'
notifier     = require 'node-notifier'
pngquant     = require 'imagemin-pngquant'
runSequence  = require 'run-sequence'
source       = require 'vinyl-source-stream'



# ---------------------------------------------------------
#  内部変数 & 関数
# ---------------------------------------------------------

# sprites生成のタスク名を格納する配列
_spritesTask = []

# JS連結のタスク名を格納する配列
_jsTasks = [ 'copyJs', 'coffee' ]

# オプションのウォッチタスク名を格納する配列
_optionsWatchTasks = []

# エラー出力
_errorHandler = (name)-> notify.onError title: "#{name} Error", message: '<%= error.message %>'

# タスク対象のファイル、ディレクトリの配列を生成
_createSrcArr = (name)->
  [].concat paths[name], [
    "!#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*"
    "!#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*/"
    "!#{SRC_DIR}/**/#{EXCRUSION_PREFIX}*/**"
  ]

# gulpのログの形式でconsole.log
_msg = (msg)->
  d = new Date()
  console.log "[#{util.colors.gray(d.getHours() + ':' + d.getMinutes() + ':' + d.getSeconds())}] #{msg}"



# ---------------------------------------------------------
#  個別タスク生成用関数
# ---------------------------------------------------------

#
# spritesmith のタスクを生成
#
# @param {String}  taskName      タスクを識別するための名前 すべてのタスク名と異なるものにする
# @param {String}  imgDir        ソース画像ディレクトリへのパス (ドキュメントルートからの相対パス)
# @param {String}  cssDir        ソースCSSディレクトリへのパス (ドキュメントルートからの相対パス)
# @param {String}  outputImgName 指定しなければ#{taskName}.pngになる
# @param {String}  outputImgPath CSSに記述される画像パス (相対パスの際に指定する)
# @param {Boolean} compressImg   画像を圧縮するかどうか
#
# #{SRC_DIR}#{imgDir}/_#{taskName}/
# 以下にソース画像を格納しておくと
# #{SRC_DIR}#{cssDir}/_#{taskName}.scss と
# #{SRC_DIR}#{imgDir}/#{taskName}.png が生成される
# かつ watch タスクの監視も追加
#
createSpritesTask = (taskName, imgDir, cssDir, outputImgName = '', outputImgPath = '', compressImg = false) ->
  _spritesTask.push taskName

  srcImgFiles = "#{SRC_DIR}/#{imgDir}/#{EXCRUSION_PREFIX}#{taskName}/*"
  paths.img.push "!#{srcImgFiles}"

  gulp.task taskName, ->

    spriteObj =
      imgName: "#{outputImgName or taskName}.png"
      cssName: "#{EXCRUSION_PREFIX}#{taskName}.scss"
      algorithm: 'binary-tree'
      padding: 2
      cssOpts:
        variableNameTransforms: ['camelize']

    if outputImgPath then spriteObj.imgPath = outputImgPath

    spriteData = gulp.src srcImgFiles
    .pipe plumber errorHandler: _errorHandler taskName
    .pipe sprite spriteObj

    imgStream = spriteData.img

    # 画像圧縮
    if compressImg
      imgStream = imgStream
      .pipe buffer()
      .pipe imagemin {
        use: [
          pngquant
            quality: '60-80'
            speed: 4
        ]
      }

    imgStream
    .pipe gulp.dest "#{SRC_DIR}/#{imgDir}"
    .pipe gulp.dest "#{PUBLISH_DIR}/#{imgDir}"

    cssStream = spriteData.css.pipe gulp.dest "#{SRC_DIR}/#{cssDir}"

    mergeStream imgStream, cssStream

  _optionsWatchTasks.unshift -> gulp.watch srcImgFiles, [ taskName ]


#
# coffee scriptでconcatする場合のタスクを生成
#
# @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
# @param {Array|String} src             ソースパス node-globのシンタックスで指定
# @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
# @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
#
createCoffeeExtractTask = (taskName, src, outputDir, outputFileName, compress = false) ->
  _jsTasks.push taskName
  if src instanceof String then src = [ src ]
  for srcPath in src then paths.coffeeInclude.push "!#{srcPath}"

  gulp.task taskName, ->
    stream = gulp.src src
    .pipe plumber errorHandler: _errorHandler taskName
    .pipe coffeelint {
      camel_case_classes: level: 'ignore'
      max_line_length: level: 'ignore'
      no_unnecessary_fat_arrows: level: 'ignore'
    }
    .pipe coffeelint.reporter()
    .pipe concat outputFileName
    .pipe coffee()
    if util.env.release or compress then stream.pipe uglify preserveComments: 'some'

    stream
    .pipe gulp.dest outputDir
    .pipe debug title: util.colors.cyan("[#{taskName}]")

  _optionsWatchTasks.push -> gulp.watch src, [ taskName ]


#
# browserifyのタスクを生成 (coffee script使用)
#
# @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
# @param {Array|String} entries         browserifyのentriesオプションに渡す node-globのシンタックスで指定
# @param {Array|String} src             entriesを除いた全ソースファイル (watchタスクで監視するため) node-globのシンタックスで指定
# @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
# @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
#
# entries以外のソースファイルを指定する理由は、coffeeInclude標準のwatchの監視の対象外にするためです。
#
createBrowserifyTask = (taskName, entries, src, outputDir, outputFileName) ->
  _jsTasks.push taskName

  if entries instanceof String then entries = [ entries ]
  for entryPath in entries then paths.coffeeInclude.push "!#{entryPath}"

  if src instanceof String then src = [ src ]
  for srcPath in src then paths.coffeeInclude.push "!#{srcPath}"

  gulp.task taskName, ->
    b = browserify
      entries: entries
      extensions: [ '.coffee' ]
    .transform 'coffeeify'
    .transform 'debowerify'

    if util.env.release then b.transform 'uglifyify'

    b.bundle()
    # .pipe plumber errorHandler: _errorHandler taskName
    .on 'error', ->
      # can't handle error by plumber
      args = Array.prototype.slice.call arguments

      notify.onError
        title: "#{taskName} Error"
        message: '<%= error.message %>'
      .apply @, args

      @emit 'end'
    .pipe source "#{outputFileName}.js"
    .pipe gulp.dest outputDir
    .pipe debug title: util.colors.cyan("[#{taskName}]")

  _optionsWatchTasks.push -> gulp.watch src, [ taskName ]


#
# javascriptのconcatタスクを生成
#
# @param {String}       taskName        タスクを識別するための名前 すべてのタスク名と異なるものにする
# @param {Array|String} src             ソースパス node-globのシンタックスで指定
# @param {String}       outputDir       最終的に出力されるjsが格納されるディレクトリ
# @param {String}       outputFileName  最終的に出力されるjsファイル名(拡張子なし)
#
createJsConcatTask = (taskName, src, outputDir, outputFileName = 'lib')->
  _jsTasks.push taskName

  gulp.task taskName, ->
    gulp.src src
    .pipe plumber errorHandler: _errorHandler 'concat'
    .pipe concat "#{outputFileName}.js", { newLine: ';' }
    .pipe uglify preserveComments: 'some'
    .pipe gulp.dest outputDir
    .pipe debug title: util.colors.cyan("[#{taskName}]")

  _optionsWatchTasks.push -> gulp.watch src, [ taskName ]



# ---------------------------------------------------------
#  タスク設定
# ---------------------------------------------------------

#############
### clean ###
#############

# clean
gulp.task 'clean', (callback)-> del CLEAN_DIR, { force: true }, callback


############
### copy ###
############

# copyHtml
gulp.task 'copyHtml', ->
  gulp.src _createSrcArr 'html'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'copyHtml'
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[copyHtml]:')

# copyCss
gulp.task 'copyCss', ->
  gulp.src _createSrcArr 'css'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'copyCss'
  .pipe autoprefixer()
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[copyCss]:')

# copyJs
gulp.task 'copyJs', ->
  stream = gulp.src _createSrcArr 'js'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'copyJs'

  if util.env.release then stream.pipe uglify preserveComments: 'some'

  stream
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[copyJs]:')

# copyJson
gulp.task 'copyJson', [ 'jsonlint' ], ->
  gulp.src _createSrcArr 'json'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'copyJson'
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[copyJson]:')

# copyImg
gulp.task 'copyImg', ->
  gulp.src _createSrcArr 'img'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'copyImg'
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[copyImg]:')

# copyOthers
gulp.task 'copyOthers', ->
  gulp.src _createSrcArr 'others'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'copyOthers'
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[copyOthers]:')


############
### html ###
############

# jade
gulp.task 'jade', ->
  gulp.src _createSrcArr 'jade'
  .pipe changed PUBLISH_DIR, { extension: '.html' }
  .pipe plumber errorHandler: _errorHandler 'jade'
  .pipe data -> require DATA_JSON
  .pipe jade
    pretty: true
    basedir: SRC_DIR
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[jade]:')

# jadeAll
gulp.task 'jadeAll', ->
  gulp.src _createSrcArr 'jade'
  .pipe plumber errorHandler: _errorHandler 'jadeAll'
  .pipe data -> require DATA_JSON
  .pipe jade
    pretty: true
    basedir: SRC_DIR
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[jadeAll]:')

# html
gulp.task 'html', [ 'copyHtml', 'jade' ]


###########
### css ###
###########

# sass
gulp.task 'sass', ->
  gulp.src _createSrcArr 'sass'
  .pipe changed PUBLISH_DIR, { extension: '.css' }
  .pipe plumber errorHandler: _errorHandler 'sass'
  .pipe sass
    outputStyle: 'expanded'
  .pipe autoprefixer()
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[sass]:')

# sassAll
gulp.task 'sassAll', ->
  gulp.src _createSrcArr 'sass'
  .pipe plumber errorHandler: _errorHandler 'sass'
  .pipe sass
    outputStyle: 'expanded'
  .pipe autoprefixer()
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[sassAll]:')

# css
gulp.task 'css', [ 'copyCss', 'sass' ]


##########
### js ###
##########

# coffee
gulp.task 'coffee', ->
  stream = gulp.src _createSrcArr 'coffee'
  .pipe changed PUBLISH_DIR, { extension: '.js' }
  .pipe plumber errorHandler: _errorHandler 'coffee'
  .pipe coffee()

  if util.env.release then stream.pipe uglify preserveComments: 'some'

  stream
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[coffee]:')

# coffeeAll
gulp.task 'coffeeAll', ->
  stream = gulp.src _createSrcArr 'coffee'
  .pipe plumber errorHandler: _errorHandler 'coffeeAll'
  .pipe coffee()

  if util.env.release then stream.pipe uglify preserveComments: 'some'

  stream
  .pipe gulp.dest PUBLISH_DIR
  .pipe debug title: util.colors.cyan('[coffeeAll]:')


############
### json ###
############

# jsonlint
gulp.task 'jsonlint', ->
  gulp.src _createSrcArr 'json'
  .pipe changed PUBLISH_DIR
  .pipe plumber errorHandler: _errorHandler 'jsonlint'
  .pipe jsonlint()
  .pipe jsonlint.reporter()
  .pipe notify (file)-> if file.jsonlint.success then false else 'jsonlint error'

# json
gulp.task 'json', [ 'copyJson' ]


################
### 個別タスク ###
################

# indexSprites
# createSpritesTask 'indexSprites', "#{ASSETS_DIR}/img", "#{ASSETS_DIR}/css", 'sprites', '../img/sprites.png', false

# lib.js
createJsConcatTask(
  'concatLibJs'
  [
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/dat.gui.min.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/axios.min.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/jquery.min.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/device.min.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/underscore-min.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/highlight.pack.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/gsap/*.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/threejs/three.min.js"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_lib/threejs/Detector.js"
  ]
  "#{PUBLISH_DIR}/#{ASSETS_DIR}/js"
  'lib'
)

# common.js
createCoffeeExtractTask(
  'commonJs'
  [
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_utils.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_init.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/shader.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/Common.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/Contents.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/MainVisual.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/TakumiGeometry.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/TakumiObject3D.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/Thumb.coffee"
    "#{SRC_DIR}/#{ASSETS_DIR}/js/_common/main.coffee"
  ]
  "#{PUBLISH_DIR}/#{ASSETS_DIR}/js"
  'common'
  true
)

for name in ['index', 'about', 'blog', 'bookmarks', 'works']
  className = name.charAt(0).toUpperCase() + name.substring(1)
  createCoffeeExtractTask(
    "#{name}Js"
    [
      "#{SRC_DIR}/#{ASSETS_DIR}/js/_init.coffee"
      "#{SRC_DIR}/#{ASSETS_DIR}/js/_#{name}/#{className}.coffee"
      "#{SRC_DIR}/#{ASSETS_DIR}/js/_#{name}/main.coffee"
    ]
    "#{PUBLISH_DIR}/#{ASSETS_DIR}/js"
    name
    true
  )


### 個別タスク設定ここまで ###


# js
gulp.task 'js', _jsTasks

# sprites
gulp.task 'sprites', _spritesTask


###############
### watcher ###
###############

# watcher
gulp.task 'watcher', ->
  # DATA_JSON更新時
  gulp.watch DATA_JSON,   [ 'jadeAll' ]

  gulp.watch _createSrcArr('html'),     [ 'copyHtml' ]
  gulp.watch _createSrcArr('css'),      [ 'copyCss' ]
  gulp.watch _createSrcArr('js'),       [ 'copyJs' ]
  gulp.watch _createSrcArr('json'),     [ 'copyJson' ]
  gulp.watch _createSrcArr('img'),      [ 'copyImg' ]
  gulp.watch _createSrcArr('others'),   [ 'copyOthers' ]
  gulp.watch _createSrcArr('jade'),     [ 'jade' ]
  gulp.watch _createSrcArr('sass'),     [ 'sass' ]
  gulp.watch _createSrcArr('coffee'),   [ 'coffee' ]


  # インクルードファイル(アンスコから始まるファイル)更新時はすべてをコンパイル
  gulp.watch paths.jadeInclude,     [ 'jadeAll' ]
  gulp.watch paths.sassInclude,     [ 'sassAll' ]
  gulp.watch paths.coffeeInclude,   [ 'coffeeAll' ]

  for task in _optionsWatchTasks then task()

  gulp.src PUBLISH_DIR
  .pipe webserver
    livereload: true
    port: 50000
    open: true
    host: '0.0.0.0'
    middleware:
      connectSSI
        baseDir: "#{__dirname}/#{PUBLISH_DIR}"
        ext: '.html'
  .pipe notify '[watcher]: start local server. http://localhost:50000/'


#############
### bower ###
#############

gulp.task 'bower', ->
  exec 'bower install', (err, stdout, stderr)->
    if err
      console.log err
    else
      # オプション指定でライブラリディレクトリに自動でインストール
      jsFilter = filter '**/*.js'
      cssFilter = filter '**/*.css'
      gulp.src bower
        debugging: true
        includeDev: true
        paths:
          bowerDirectory: './bower_components'
          bowerJson: 'bower.json'
      .pipe plumber errorHandler: _errorHandler
      .pipe jsFilter
      .pipe gulp.dest "#{SRC_DIR}/#{ASSETS_DIR}/js/#{EXCRUSION_PREFIX}#{LIBRARY_DIR_NAME}"
      .pipe jsFilter.restore()
      .pipe cssFilter
      .pipe gulp.dest "#{SRC_DIR}/#{ASSETS_DIR}/css/#{EXCRUSION_PREFIX}#{LIBRARY_DIR_NAME}"
      .pipe cssFilter.restore()
      .pipe debug title: util.colors.cyan('[bower]:')




###############
### default ###
###############

gulp.task 'default', [ 'clean' ], ->
  runSequence [ 'json', 'sprites' ], [ 'html', 'css', 'js', 'copyImg', 'copyOthers' ], ->
    _msg util.colors.yellow '##################################'
    _msg util.colors.yellow '###      build complete!!      ###'
    _msg util.colors.yellow '##################################'
    notifier.notify title: 'gulp', message: 'build complete!!'
