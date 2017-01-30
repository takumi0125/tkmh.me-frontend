############
### pug ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  # pug
  gulp.task 'pug', ->
    gulp.src utils.createSrcArr 'pug'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.html' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'pug'
    .pipe gulpPlugins.data -> return require(config.pugData)
    .pipe gulpPlugins.pug
      pretty: true
      basedir: config.srcDir
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[pug]:')

  # pugAll
  gulp.task 'pugAll', ->
    gulp.src utils.createSrcArr 'pug'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'pugAll'
    .pipe gulpPlugins.data -> return require(config.pugData)
    .pipe gulpPlugins.pug
      pretty: true
      basedir: config.srcDir
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[pugAll]:')
