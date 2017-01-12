class tkmh.blog.Blog extends tkmh.common.Contents
  constructor: ->
    super()


  init: ->
    super()

    @initThumbs()
    @initSearchPanel 'blog'

    # detail
    @initImgs 'article.main .img img'

    # btnBack
    @initBtnBack 'blog'

    # highlight js
    @$contentsInner.find('code > pre').each (index, block)->
      hljs.highlightBlock block

    # window resize
    @$window.on 'resize.contents', @resizeSearchPanel
    .trigger 'resize.contents'

    return



  start: ->
    tkmh.common.animateToTtl 'blog'
    return


  reset: ->
    @$window.off 'resize.contents'
    @resetSearchPanel()
    @resetBtnBack()
    return
