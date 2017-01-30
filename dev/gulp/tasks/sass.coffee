############
### sass ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  # sass
  gulp.task 'sass', ->
    cssFilter = gulpPlugins.filter [ '**/*.css'], { restore: true }

    stream = gulp.src utils.createSrcArr 'sass'
    .pipe gulpPlugins.changed config.publishDir, { extension: '.css' }
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'sass'

    stream = utils.sourcemap stream, (stream)->
      return stream.pipe gulpPlugins.sass outputStyle: 'expanded'

    stream
    .pipe cssFilter
    .pipe gulpPlugins.autoprefixer(browsers: config.autoprefixerOpt)
    .pipe cssFilter.restore

    stream = utils.compressCss stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[sass]:')


  # sassAll
  gulp.task 'sassAll', ->
    cssFilter = gulpPlugins.filter [ '**/*.css' ], { restore: true }

    stream = gulp.src utils.createSrcArr 'sass'
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'sass'

    stream = utils.sourcemap stream, (stream)->
      return stream.pipe gulpPlugins.sass outputStyle: 'expanded'

    stream
    .pipe cssFilter
    .pipe gulpPlugins.autoprefixer(browsers: config.autoprefixerOpt)
    .pipe cssFilter.restore

    stream = utils.compressCss stream

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[sassAll]:')
