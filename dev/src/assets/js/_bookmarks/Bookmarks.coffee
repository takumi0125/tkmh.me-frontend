Contents = require '../_common/Contents'

class Bookmarks extends Contents
  constructor: ->
    super 'bookmarks'


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
    tkmh.animateToTtl 'bookmarks'
    return


  reset: ->
    @$window.off 'resize.contents'
    @resetSearchPanel()
    @resetBtnBack()
    return

module.exports = Bookmarks
