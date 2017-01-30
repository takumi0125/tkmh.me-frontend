#############
### clean ###
#############

del = require 'del'
module.exports = (gulp, gulpPlugins, config, utils)->
  gulp.task 'clean', (callback)-> del "#{config.publishDir}#{config.clearDir}", { force: true }, callback
