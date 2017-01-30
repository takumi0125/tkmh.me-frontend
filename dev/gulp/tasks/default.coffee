###############
### default ###
###############

runSequence = require 'run-sequence'
notifier    = require 'node-notifier'

module.exports = (gulp, gulpPlugins, config, utils)->
  gulp.task 'default', [ 'clean' ], ->
    runSequence [ 'json', 'sprites' ], [ 'html', 'css', 'js', 'copyImg', 'copyOthers' ], ->
      utils.msg gulpPlugins.util.colors.yellow '##################################'
      utils.msg gulpPlugins.util.colors.yellow '###      build complete!!      ###'
      utils.msg gulpPlugins.util.colors.yellow '##################################'
      notifier.notify title: 'gulp', message: 'build complete!!'
