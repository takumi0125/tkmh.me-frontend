####################
### custom tasks ###
####################

module.exports = (gulp, gulpPlugins, config, utils)->
  # lib.js
  utils.createJsConcatTask(
    'concatLibJs'
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/threejs/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_lib/gsap/*"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'lib'
  )

  # common.js
  utils.createWebpackJsTask(
    'commonJs'
    [ "#{config.srcDir}/#{config.assetsDir}/js/_common/init.coffee" ]
    [
      "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
      "#{config.srcDir}/#{config.assetsDir}/js/_common/**/*"
    ]
    "#{config.publishDir}/#{config.assetsDir}/js"
    'common'
  )


  for key in ['Index', 'Blog', 'Bookmarks', 'About', 'Works']
    lowerKey = key.toLowerCase()
    utils.createWebpackJsTask(
      "#{lowerKey}Js"
      [ "#{config.srcDir}/#{config.assetsDir}/js/_#{lowerKey}/init.coffee" ]
      [
        "#{config.srcDir}/#{config.assetsDir}/js/_utils/**/*"
        "#{config.srcDir}/#{config.assetsDir}/js/_#{lowerKey}/**/*"
        "#{config.srcDir}/#{config.assetsDir}/js/_common/Contents.coffee"
      ]
      "#{config.publishDir}/#{config.assetsDir}/js"
      lowerKey
    )
