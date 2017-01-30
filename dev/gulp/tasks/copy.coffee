############
### copy ###
############

module.exports = (gulp, gulpPlugins, config, utils)->
  # copyHtml
  gulp.task 'copyHtml', ->
    gulp.src utils.createSrcArr 'html'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'copyHtml'
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[copyHtml]:')


  # copyCss
  gulp.task 'copyCss', ->
    stream = gulp.src utils.createSrcArr 'css'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'copyCss'
    .pipe gulpPlugins.autoprefixer()

    stream = utils.compressCss stream, true

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[copyCss]:')


  # copyJs
  gulp.task 'copyJs', ->
    stream = gulp.src utils.createSrcArr 'js'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'copyJs'

    stream = utils.compressJs stream, true

    stream
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[copyJs]:')


  # copyJson
  gulp.task 'copyJson', [ 'jsonlint' ], ->
    gulp.src utils.createSrcArr 'json'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'copyJson'
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[copyJson]:')


  # copyImg
  gulp.task 'copyImg', ->
    gulp.src utils.createSrcArr 'img'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'copyImg'
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[copyImg]:')


  # copyOthers
  gulp.task 'copyOthers', ->
    gulp.src utils.createSrcArr 'others'
    .pipe gulpPlugins.changed config.publishDir
    .pipe gulpPlugins.plumber errorHandler: utils.errorHandler 'copyOthers'
    .pipe gulp.dest config.publishDir
    .pipe gulpPlugins.debug title: gulpPlugins.util.colors.cyan('[copyOthers]:')
