#############
### bower ###
#############

bower = require 'main-bower-files'
exec  = require('child_process').exec

module.exports = (gulp, gulpPlugins, config, utils)->
  gulp.task 'bower', ->
    exec 'bower install', (err, stdout, stderr)->
      if err
        console.log err
      else
        # オプション指定でライブラリディレクトリに自動でインストール
        jsFilter = gulpPlugins.filter '**/*.js', { restore: true }
        cssFilter = gulpPlugins.filter '**/*.scss', { restore: true }
        gulp.src bower
          debugging: true
          includeDev: true
          paths:
            bowerDirectory: './bower_components'
            bowerJson: 'bower.json'
        .pipe gulpPlugins.plumber errorHandler: utils.errorHandler
        .pipe cssFilter
        .pipe gulp.dest "#{config.srcDir}/#{config.assetsDir}/css/#{config.excrusionPrefix}#{config.libraryDirName}"
        .pipe cssFilter.restore
        .pipe jsFilter
        .pipe gulp.dest "#{config.srcDir}/#{config.assetsDir}/js/#{config.excrusionPrefix}#{config.libraryDirName}"
        .pipe jsFilter.restore
        .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[bower]:')
