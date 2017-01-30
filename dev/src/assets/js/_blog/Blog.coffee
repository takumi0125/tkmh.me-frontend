Contents = require '../_common/Contents'

class Blog extends Contents
  constructor: ->
    super 'blog'


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
    tkmh.animateToTtl 'blog'
    return


  reset: ->
    @$window.off 'resize.contents'
    @resetSearchPanel()
    @resetBtnBack()
    return


module.exports = Blog
