class tkmh.bookmarks.Bookmarks extends tkmh.common.Contents
  constructor: ->
    super()


  init: ->
    super()

    @initThumbs()
    @initSearchPanel 'bookmarks'

    # btnBack
    @initBtnBack 'bookmarks'

    # detail
    @initImgs 'article.main .capture img'

    # window resize
    @$window.on 'resize.contents', @resizeSearchPanel
    .trigger 'resize.contents'

    return



  start: ->
    tkmh.common.animateToTtl 'bookmarks'
    return


  reset: ->
    @$window.off 'resize.contents'
    @resetSearchPanel()
    @resetBtnBack()
    return
