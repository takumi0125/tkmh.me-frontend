utils = require '../_utils/utils'
Contents = require '../_common/Contents'

class Works extends Contents
  constructor: ->
    super 'works'


  init: ->
    super()

    @initThumbs()
    @initSearchPanel 'works'

    # detail
    @initImgs 'article.main .img img'

    # btnBack
    @initBtnBack 'works'

    # thumb interaction
    @initThumbsInteraction 'section.articles article .thumb', 20, 10

    # resize
    @$window.on 'resize.contents', (e)=>
      @resizeSearchPanel()
      if utils.isDesktop
        for thumb in @thumbs then thumb.resize()
      return
    .trigger 'resize.contents'

    return


  start: ->
    tkmh.animateToTtl 'works'
    return


  reset: ->
    # @$window.off 'resize.contents'
    @resetSearchPanel()
    @resetBtnBack()
    @disposeThumbsInteraction()
    return

module.exports = Works
