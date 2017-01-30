##############
### coffee ###
##############

module.exports = (gulp, gulpPlugins, config, utils)->
  # coffee
  gulp.task 'coffee', ->
    stream = gulp.src utils.createSrcArr 'coffee'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.js' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'coffee'

    stream = utils.sourcemap stream, (stream)->
      stream = stream.pipe gulpPlugins.coffee()
      return utils.compressJs stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[coffee]:')


  # coffeeAll
  gulp.task 'coffeeAll', ->
    stream = gulp.src utils.createSrcArr 'coffee'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'coffeeAll'

    stream = utils.sourcemap stream, (stream)->
      stream = stream.pipe gulpPlugins.coffee()
      return utils.compressJs stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[coffeeAll]:')
