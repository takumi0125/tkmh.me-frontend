class tkmh.works.Works extends tkmh.common.Contents
  constructor: ->
    super()


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
      if device.desktop()
        for thumb in @thumbs then thumb.resize()
      return
    .trigger 'resize.contents'

    return


  start: ->
    tkmh.common.animateToTtl 'works'
    return


  reset: ->
    # @$window.off 'resize.contents'
    @resetSearchPanel()
    @resetBtnBack()
    @disposeThumbsInteraction()
    return
