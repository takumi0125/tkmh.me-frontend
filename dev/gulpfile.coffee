#
# フロントエンド開発用 汎用gulpテンプレート
#

# config
config = require('./gulp/config')(__dirname)

# modules
gulp        = require 'gulp'
gulpPlugins = require('gulp-load-plugins')()
utils       = require('./gulp/utils')(gulp, gulpPlugins, config)

# --releaseオプションが指定されている場合はsourcemapは作らない
if gulpPlugins.util.env.release
  config.sourcemap = false


# --------------------------
#  各種内部変数 (configに追加)
# --------------------------

# sprites生成のタスク名を格納する配列
config.spritesTaskNames = []

# JS連結のタスク名を格納する配列
config.jsConcatTaskNames = []

# オプションのウォッチタスクを格納する配列
config.optionsWatchTasks = []



# --------------------------
#  タスク定義
# --------------------------

### 基本タスク ###

# clean
require('./gulp/tasks/clean')(gulp, gulpPlugins, config, utils)

# bower
require('./gulp/tasks/bower')(gulp, gulpPlugins, config, utils)

# copy
require('./gulp/tasks/copy')(gulp, gulpPlugins, config, utils)

# json
require('./gulp/tasks/json')(gulp, gulpPlugins, config, utils)

# pug (jade)
require('./gulp/tasks/pug')(gulp, gulpPlugins, config, utils)

# sass
require('./gulp/tasks/sass')(gulp, gulpPlugins, config, utils)

# coffee
require('./gulp/tasks/coffee')(gulp, gulpPlugins, config, utils)


###
カスタムタスク
JSの結合, Browserify, Webpack, spritesmithのタスク定義
基本的にはプロジェクトごとにこのファイルとconfigを編集することになる
###

require('./gulp/customTasks')(gulp, gulpPlugins, config, utils)


### 複合タスク ###

# html
gulp.task 'html', [ 'copyHtml', 'pug' ]

# css
gulp.task 'css', [ 'copyCss', 'sass' ]

# json
gulp.task 'json', [ 'copyJson' ]

# js
gulp.task 'js', config.jsConcatTaskNames.concat([ 'copyJs', 'coffee' ])

# sprites
gulp.task 'sprites', config.spritesTaskNames


### watchタスク (watch & ローカルサーバを起動) ###

require('./gulp/tasks/watch')(gulp, gulpPlugins, config, utils)



### defaultタスク ###

require('./gulp/tasks/default')(gulp, gulpPlugins, config, utils)
