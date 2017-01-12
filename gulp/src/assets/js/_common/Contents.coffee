class tkmh.common.Contents
  constructor: ->
    tkmh.common.currentContents = @


  reset: ->


  start: ->


  init: ->
    @$window = $ window
    @$body = $ 'body'
    @$contents = $ '#contents'
    @$contentsInner = $ '#contentsInner'
    @$mainVisual = $ '#mainVisual'
    @$globalHeader = $ '#globalHeader'
    return


  initThumbs: ->
    @initImgs '.articles .thumb img'
    return


  initImgs: (selector)->
    @$contentsInner.find(selector).each (index, img)->
      utils.preloadImg img.src
      .then ->
        $(img).one utils.TRANSITION_END, (e)->
          e.stopPropagation()
          return false
        .addClass 'loaded'
    return


  initThumbsInteraction: (selector, widthSegments = 10, heightSegments = 10)->
    if !device.desktop() then return
    self = @
    @thumbs = []
    @$contentsInner.find(selector).each (index, img)->
      thumb = new tkmh.common.Thumb $(@), widthSegments, heightSegments
      self.thumbs.push thumb
      thumb.init()

    return


  disposeThumbsInteraction: ->
    if !device.desktop() then return
    for thumb in @thumbs then thumb.dispose()
    return


  initBtnBack: (dir)->
    @$btnBack = @$searchPanel.find('.btnBack').on 'click', (e)=>
      tkmh.back "/#{dir}/"
      e.preventDefault()
      return false
    return


  resetBtnBack: ->
    @$btnBack.off 'click'
    return


  initSearchPanel: (dir)->
    @$searchPanel = $ '#searchPanel'
    @$categories = @$searchPanel.find '.categories'
    @$tags = @$searchPanel.find '.tags'
    @$monthlyArchives = @$searchPanel.find '.monthlyArchives'
    @$keyword = @$searchPanel.find '.keyword'
    $keywordInput = @$keyword.find 'input'

    @$keyword.find('.btnSubmit').on 'click', (e)=>
      tkmh.searchByKeyword dir, "?s=#{$keywordInput.val()}"
      e.preventDefault()
      return false

    toggleContens = ($btn, $contents, toggle = true)=>
      if toggle
        $btn.toggleClass 'closed'
        $contents.toggleClass 'closed'
      else
        $btn.addClass 'closed'
        $contents.addClass 'closed'

    @$btnCategories = @$searchPanel.find '.btnCategories'
    .on 'click', (e)=>
      toggleContens @$btnCategories, @$categories
      toggleContens @$btnTags, @$tags, false
      toggleContens @$btnMonthlyArchives, @$monthlyArchives, false
      toggleContens @$btnKeyword, @$keyword, false
      return false

    @$btnTags = @$searchPanel.find '.btnTags'
    .on 'click', (e)=>
      toggleContens @$btnCategories, @$categories, false
      toggleContens @$btnTags, @$tags
      toggleContens @$btnMonthlyArchives, @$monthlyArchives, false
      toggleContens @$btnKeyword, @$keyword, false
      return false

    @$btnMonthlyArchives = @$searchPanel.find '.btnMonthlyArchives'
    .on 'click', (e)=>
      toggleContens @$btnCategories, @$categories, false
      toggleContens @$btnTags, @$tags, false
      toggleContens @$btnMonthlyArchives, @$monthlyArchives
      toggleContens @$btnKeyword, @$keyword, false
      return false

    @$btnKeyword = @$searchPanel.find '.btnKeyword'
    .on 'click', (e)=>
      toggleContens @$btnCategories, @$categories, false
      toggleContens @$btnTags, @$tags, false
      toggleContens @$btnMonthlyArchives, @$monthlyArchives, false
      toggleContens @$btnKeyword, @$keyword
      return false

    return


  resizeSearchPanel: =>
    @$categories.css 'height', @$categories.find('ul').outerHeight()
    @$tags.css 'height', @$tags.find('ul').outerHeight()
    @$monthlyArchives.css 'height', @$monthlyArchives.find('ul').outerHeight()
    @$keyword.css 'height', @$keyword.find('form').outerHeight()
    return


  resetSearchPanel: ->
    @$btnCategories.off 'click'
    @$btnTags.off 'click'
    @$btnMonthlyArchives.off 'click'
    @$btnKeyword.off 'click'
    return
