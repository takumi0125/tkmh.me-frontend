class tkmh.common.Common
  _CAM_DISTANCE = 20
  _MIN_HEIGHT = 600
  _CONTENTS_INNER_ID = 'contentsInner'
  _SAME_CAT_CONTAINER_SELECTOR = '> .inner'
  _CONTENTS_CONTAINER_CLASS = 'contentsContainer'

  constructor: ->
    @$window = $ window
    @$body = $ 'body'
    @$wrapper = $ '#wrapper'
    @$contentsInner = $ "##{_CONTENTS_INNER_ID}"
    @$globalHeader = $ '#globalHeader'
    @$globalNav = $ '#globalNav'
    @$mainVisual = $ '#mainVisual'

    @requestAnimationFrameId = null
    @updateFuncs = []

    # モバイル用 グロナビを切り替え
    $('#btnMenu a').on 'click', (e)=>
      @$body.toggleClass 'menuOpened'
      e.preventDefault()
      e.stopImmediatePropagation()

    # メインビジュアルのスクロールボタン
    @$mainVisual.find('.btnScroll').on 'click', (e)=>
      scrollTo = @$mainVisual.height() - @$globalHeader.height()
      utils.windowScrollTo scrollTo, 0.6
      return false

    # 画面最後のスクロールトップボタン
    @$wrapper.find('.btnScrollTop').on 'click', (e)->
      utils.windowScrollTo 0, 0.6
      return false

    @initAsyncTransition()

    # window
    @$window.on
      popstate: (e)=>
        if !@isInited then return
        if @lastUrl is ''
          # トップの場合何もしない
        else
          @registerHistory '', true
          @showContents @lastUrl, location.pathname

      scroll: (e)=> @scrollTop = @$window.scrollTop()

      resize: @windowResizeHandler


    # メインビジュアル(webGL)サポート時のみ
    @mainVisual = new tkmh.common.MainVisual()

    # 外からタイトルを切り替える用
    tkmh.common.animateToTtl = (name)=>
      if !@mainVisual.isWebGLSupported then return
      @mainVisual.animateToTtl name
      return

    tkmh.common.animateFromTtl = =>
      if !@mainVisual.isWebGLSupported then return
      @mainVisual?.animateFromTtl()
      return


    @$window.trigger 'resize'
    @$window.trigger 'scroll'
    # if tkmh.isWindowLoaded then @$window.trigger 'load'

    @mainVisual.init =>
      if @mainVisual.isWebGLSupported
        @$window.off 'resize'
        @$window.on
          resize: (e)=>
            @windowResizeHandler e
            @mainVisual.resize(
              @$window.width()
              @mainVisualHeight - 1
            )
            return
          mousemove: @mainVisual.windowMouseMoveHandler
          devicemotion: @mainVisual.deviceMotionHandler
        .trigger 'resize'

        @updateFuncs[0] = @mainVisual.draw

      # document ready
      $loading = $('#loading').addClass('loaded').on utils.TRANSITION_END, (e)=>
        $loading.remove()
        url = location.pathname
        @registerHistory url
        @showContents '', url, true


    # search
    tkmh.searchByKeyword = (category, query)=>
      @loadPage "/#{category}/#{query}", null, true
      return


    # back
    tkmh.back = (defaultPath)=>
      urlHistory = @registerHistory '', true
      lastUrl = (urlHistory.length > 0 and urlHistory[urlHistory.length - 1]) or defaultPath
      history.pushState { url: lastUrl, lastUrl: @lastUrl }, '', lastUrl
      @showContents @lastUrl, lastUrl
      return

    @update()



  registerHistory: (url, remove = false)->
    if !sessionStorage? then return false

    urlHistory = @getHistory()

    if remove
      urlHistory.pop()
    else
      if urlHistory[urlHistory.length - 1] isnt url
        urlHistory.push url

    sessionStorage.setItem 'history', urlHistory.join(',')
    return urlHistory


  getHistory: ->
    if !sessionStorage? then return false
    urlHistory = []
    urlHistoryStr = sessionStorage.getItem('history')
    if urlHistoryStr
      urlHistory = urlHistoryStr.split ','
    return urlHistory


  # window resize
  windowResizeHandler: (e = null)=>
    @mainVisualHeight = @$mainVisual.height()
    @headerHeight = @$globalHeader.height()


  # 非同期遷移イニシャライズ
  initAsyncTransition: ->
    @lastUrl = ''
    @bodyClass = ''
    @isInited = false
    @isAnimating = false
    @$syncItems = null
    @$insertContents = null
    @currentContents = null
    @$currentContentsContainer = @$contentsInner

    # 同期するhead内のセレクタ
    @syncMetaSelectors = [
      'title'
      'meta[name="keywords"]'
      'meta[name="description"]'
      'meta[property="og:title"]'
      'meta[property="og:url"]'
      'meta[property="og:description"]'
      'meta[property="og:image"]'
      'meta[property="og:type"]'
    ]

    # CSS
    @syncStyleSelectors = [
      'link[rel="stylesheet"]:not([href="/assets/css/common.css"])'
    ]

    # script
    notSyncScripts = [
      '[src*="livereload"]'
      '[src*="localhost"]'
      '[src="/assets/js/common.js"]'
      '[src="/assets/js/lib.js"]'
      '[type="text/template"]'
      '.nosync'
    ]

    @syncScriptSelectors = [
      "script:not(" + (notSyncScripts.join(',')) + ")"
    ]

    @$syncStyles = $ @syncStyleSelectors.join(',')
    @$syncMetas = $ @syncMetaSelectors.join(',')
    @$syncScripts = $ @syncScriptSelectors.join(',')
    @getInsertContents @$body, false


    # リンククリックの挙動
    self = @
    @$body
    .on 'click', 'a[href="#"],a.notransition', (e)->
      # 何もしない
      e.preventDefault()
      return false
    .on 'click', 'a:not([target],[href^="#"],[href="#"],a.notransition)', (e)->
      # pusuState遷移
      self.loadPage $(@).attr('href')
      e.preventDefault()
      return false


    # test
    if !device.desktop()
      @$globalNav.find('li a').on 'click', (e)->
        self.$body.removeClass 'menuOpened'
        href = $(@).attr('href')
        d = $.Deferred()

        self.$globalNav.one utils.TRANSITION_END, (e)->
          if e.target.id is 'globalNav'
            d.resolve()

        self.loadPage href, d.promise()

        e.preventDefault()
        e.stopPropagation()
        return false

    return


  # 表示するコンテンツを取得
  getInsertContents: ($html, fromAjaxLoadedContents = true, isSameCat = false)->
    # metaやcss、scriptなどの同期するアイテムを取得
    filterStr = [].concat(@syncMetaSelectors, @syncStyleSelectors, @syncScriptSelectors, @syncLinks).join(',')
    filterStr = filterStr.replace /,$/, ''
    if fromAjaxLoadedContents
      # ajaxでロードしたもの
      @$syncItems = $html.filter(filterStr)
    else
      # ajaxでロードしていないもの
      @$syncItems = $(filterStr).clone()

    if isSameCat
      @$insertContents = $html.find("##{_CONTENTS_INNER_ID} #{_SAME_CAT_CONTAINER_SELECTOR}").children()
    else
      @$insertContents = $html.find("##{_CONTENTS_INNER_ID}").children()
    return


  # ページを読み込み
  loadPage: (url, externalDeferred = null, force = false)->
    if @isAnimating then return

    url = @removeHostsFromUrl url
    currentURL = location.pathname

    if (url is currentURL) and !force then return

    # push state
    history.pushState { url: url, lastUrl: @lastUrl }, '', url
    @registerHistory url


    @showContents currentURL, url, false, externalDeferred

    return


  # ajaxでコンテンツをロード
  ajaxPageLoad: (url, isSameCat = false)->
    return axios.get url
    .then (response)=>
      if response.status is 200
        # 成功時にコンテンツ反映
        htmlTxt = response.data
        @bodyClass = htmlTxt.match(/<body[^<>'"]*class="(.*)"/)[1]
        $html = $ htmlTxt.replace(/([.\s\S　]*)<html([^>]*)>([.\s\S　]*)<\/html>/, "$3")
        @getInsertContents $html, true, isSameCat
      else
        log 'ajax error', response.statusText

    .catch (error)->
      # エラーの場合はそのまま遷移させてエラー画面を表示
      log 'ajax error', error

    return



  # ロードしたコンテンツを反映
  setLoadedContents: =>
    d = $.Deferred()

    self = this
    numTotalSyncItems = 0
    numLoadedSyncItems = 0

    # body class
    @$body.attr 'class', @bodyClass

    # 各コンテンツロード時のコールバック
    contentsLoadHandler = (e = null)=>
      # log 'loading...' + (numLoadedSyncItems + 1) + '/' + numTotalSyncItems
      if numTotalSyncItems is 0 or ++numLoadedSyncItems is numTotalSyncItems
        @$syncScripts.remove()
        @$syncScripts = $ @syncScriptSelectors.join(',')

        @$syncStyles.remove()
        @$syncStyles = $ @syncStyleSelectors.join(',')

        @$window.resize().scroll()

        d.resolve()
        return

    # metaタグ等の情報を切り替え
    $.each @syncMetaSelectors, (index)=>
      selector = @syncMetaSelectors[index]
      $obj = @$syncMetas.filter selector
      if $obj.attr('content')
        # meta
        $obj.attr 'content', @$syncItems.filter(selector).attr('content')
      else
        # title
        $obj.text @$syncItems.filter(selector).text()
      return

    # cssを切り替え
    $lastStyleTag = $('link[rel="stylesheet"]').last()
    $stylesToAdd = null
    $.each @syncStyleSelectors, (index)=>
      selector = @syncStyleSelectors[index]
      $stylesToAdd = @$syncItems.filter selector
      $stylesToAdd.each (i)=>
        $styleToAdd = $stylesToAdd.eq(i)
        $style = $('<link>').insertAfter($lastStyleTag)
        .one 'load', (e)=>
          # log 'css loaded', e
          contentsLoadHandler()
        .attr
          rel: 'stylesheet'
          type: 'text/css'
          href: $styleToAdd.attr 'href'
          media: $styleToAdd.attr 'media'
        return
      numTotalSyncItems += $stylesToAdd.length
      return

    # jsを切り替え
    $lastScriptTag = $('script').last()
    $scriptsToAdd = null
    $.each @syncScriptSelectors, (index)=>
      selector = @syncScriptSelectors[index]
      $scriptsToAdd = @$syncItems.filter selector
      $scriptsToAdd.each (i)=>
        $scriptToAdd = $scriptsToAdd.eq i
        src = $scriptToAdd.attr 'src'
        $script = $ '<script>'
        .insertAfter $lastScriptTag
        .attr 'type', 'text/javascript'
        if src?
          # 外部ファイル
          $script.one 'load', (e)=>
            # log 'js loaded'
            contentsLoadHandler()
            return
          .attr 'src', src
        else
          # インライン
          $script.html $scriptToAdd.html()
          setTimeout (=>
            contentsLoadHandler()
          ), 400

        return
      numTotalSyncItems += $scriptsToAdd.length
      return

    # コンテンツを切り替え
    @$currentContentsContainer.children().remove()
    @$currentContentsContainer.html @$insertContents

    return d.promise()


  removeHostsFromUrl: (url)->
    if url.indexOf(location.host) >= 0
      pattern = new RegExp "#{location.protocol}//#{location.host}"
      return url.replace pattern, ''
    return url



  # コンテンツ切り替え
  showContents: (urlFrom, urlTo, noLoad = false, externalDeferred = null)->
    urlTo = @removeHostsFromUrl urlTo

    if @isAnimating or urlFrom is urlTo then return

    @$currentContentsContainer = @$contentsInner
    @lastUrl = urlTo
    @isAnimating = true
    pathsFrom = @getPathArr urlFrom
    pathsTo = @getPathArr urlTo
    catFrom = pathsFrom[0]
    catTo = pathsTo[0]

    if noLoad
      # ロードなし (最初の読み込み時)
      @isInited = true
      @startContents true
      return
    else
      # コンテンツをロードして開始
      if catTo is ''
        # トップへ遷移する場合またはトップから遷移する場合
        @$body.addClass 'hiding'

      isSameCat = false
      scrollTo = 0
      if catFrom is catTo
        isSameCat = true
        @$currentContentsContainer = @$contentsInner.find(_SAME_CAT_CONTAINER_SELECTOR)

        # 同カテゴリ内の場合はスクロール位置を調整
        scrollTo = @$window.height() - @$globalHeader.height()

        # コンテンツの高さをキープする
        @$contentsInner.css 'height', @$contentsInner.outerHeight()

      @$currentContentsContainer.addClass _CONTENTS_CONTAINER_CLASS

      promises = [
        @ajaxPageLoad @lastUrl, isSameCat
        @fadeOutContents scrollTo
      ]

      if externalDeferred then promises.push externalDeferred

      $.when.apply(@, promises).then =>
        # 読み込んだコンテンツをセット
        return @setLoadedContents()

      .then =>
        # GA
        ga? 'send', 'pageview', urlTo
        @startContents()
    return


  # コンテンツをスタート
  startContents: (noLoad = false)=>
    @$body.addClass('show').removeClass 'hide'

    @currentContents = tkmh.common.currentContents
    @currentContents.init()

    _start = (e = null)=>
      @$contentsInner.css 'height', ''
      @$wrapper.removeClass 'hiding'
      @currentContents.start()
      @isAnimating = false
      return

    if noLoad
      # ロードなし (最初の読み込み時)
      _start()
      return

    else
      # ロードあり
      TweenMax.to @$currentContentsContainer, 0.2, {
        opacity: 1
        delay: 0.2
        ease: Linear.easeNone
        onComplete: =>
          @$currentContentsContainer.removeClass _CONTENTS_CONTAINER_CLASS
          _start()
          return
      }

    return


  # コンテンツエリアをフェードアウト
  fadeOutContents: (scrollTo)->
    d = $.Deferred()

    @$body.addClass('hide').removeClass 'show'
    utils.windowScrollTo(scrollTo).then =>
      TweenMax.to @$currentContentsContainer, 0.2, {
        opacity: 0
        ease: Linear.easeNone
        onComplete: =>
          if @currentContents then @currentContents.reset()
          d.resolve()
          return
      }

    return d.promise()


  # URLからパスを取得
  getPathArr: (url)->
    pathArr = url.split '/'
    pathArr.splice(0, 1)
    if pathArr.length isnt 1 and pathArr[pathArr.length - 1] is ''
      pathArr.pop()
    return pathArr


  # 画面更新
  update: =>
    if @scrollTop >= @mainVisualHeight - @headerHeight
      @$body.addClass 'scrolled'
    else
      @$body.removeClass 'scrolled'

    for func in @updateFuncs then func?()

    @requestAnimationFrameId = requestAnimationFrame @update
