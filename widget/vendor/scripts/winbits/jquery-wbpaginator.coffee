'use strict'

(($) ->
  $.widget 'winbits.wbpaginator',
    _MAX_PAGES: 10

    options:
      max: 10
      page: 1

    _create: ->
      @element.hide()
      @_setOption('total', @options.total)
      @_setOption('max', @options.max)
      @_updateTotalPages()
      @_setOption('page', @options.page)
      @_createPagerText()
      @_createPagersList()
      @_bindPagersEvents()
      @_refresh()

    _setOption: (key, value) ->
      constrainFunction = @_constrainFunctions[key]
      if typeof constrainFunction is 'function'
        value = constrainFunction.call(@, value)
      @_super(key, value)

    _constrainFunctions:
      total: (total) ->
        if typeof total is 'number'
          Math.ceil(total)

      max: (max) ->
        if typeof max is 'number' and max >= 1 and max <= @options.total
          Math.ceil(max)
        else
          10

      page: (page) ->
        if typeof page is 'number' and page >= 1 and page <= @_totalPages
          Math.ceil(page)
        else
          1

    _updateTotalPages: ->
      @_totalPages = @_getTotalPages()

    _setOptions: (options) ->
      @_super(options)

    _getTotalPages: ->
      Math.ceil(@options.total / @options.max)

    _createPagerText: ->
      page = @options.page
      @_pagerText = $('<p></p>', class: 'wbc-pager-text')
        .text("Página #{page} de #{@_totalPages}")
        .appendTo(@element)

    _createPagersList: ->
      @_$pagersList = $('<ul></ul>', class: 'wbc-pagers').appendTo(@element)
      @_createPagers()

    _createPagers: ->
      @_createHeadPagers()
      @_createTailPagers()
      @_createEllipsisPager()
      @_createPreviousPagePager()
      @_createNextPagePager()

    _createHeadPagers: ->
      endIndex = @_getMiddleIndex()
      headPagers = (@_createPager().get(0) for i in [1..endIndex])
      @_$headPagers = $(headPagers).appendTo(@_$pagersList)

    _getMiddleIndex: ->
      Math.floor(@_MAX_PAGES / 2)

    _createPager: (pagerClass = 'wbc-pager', linkClass = 'wbc-pager-link') ->
      $('<li></li>', class: pagerClass)
        .append('<a></a>', href: '#', class: linkClass)

    _createEllipsisPager: ->
      middleIndex = @_getMiddleIndex()
      @_$ellipsisPager = @_createPager('wbc-ellipsis-pager', '')
        .insertAfter(@_$headPagers.last())

      @_$ellipsisPager.find('a').text('...')

    _createTailPagers: ->
      startIndex = @_getMiddleIndex() + 1
      tailPagers = (@_createPager().get(0) for i in [startIndex..@_MAX_PAGES])
      @_$tailPagers = $(tailPagers).appendTo(@_$pagersList)

    _createPreviousPagePager: ->
      @_$previousPager = $('<li></li>', class: 'wbc-previous-pager pager-prev')
      $pagerLink = $('<a></a>', href: '#')
        .text(' Ant')
        .appendTo(@_$previousPager)
      $('<span></span>', class: 'iconFont-arrowLeft').prependTo($pagerLink)
      @_$previousPager.prependTo(@_$pagersList)

    _createNextPagePager: ->
      @_$nextPager = $('<li></li>', class: 'wbc-next-pager pager-next')
      $pagerLink = $('<a></a>', href: '#', class: 'wbc-next-pager-link')
        .text('Sig ')
        .appendTo(@_$nextPager)
      $('<span></span>', class: 'iconFont-arrowRight').appendTo($pagerLink)
      @_$nextPager.appendTo(@_$pagersList)

    _bindPagersEvents: ->
      @_$pagersList.on('click', 'a', (e) -> e.preventDefault())
      @_$pagersList.on('click', 'li.wbc-previous-pager',
        $.proxy(@_previousPagerClicked, @))
      @_$pagersList.on('click', 'li.wbc-next-pager',
        $.proxy(@_nextPagerClicked, @))
      @_$pagersList.on('click', 'li.wbc-pager', $.proxy(@_pagerClicked, @))

    _previousPagerClicked: (e) ->
      if @options.page > 1
        @options.page = @options.page - 1
        @_refreshPagerText()
        @_triggerChangePageEvent(e)

    _triggerChangePageEvent: (e) ->
      @_trigger('change', e,
        total: @options.total
        max: @options.max
        page: @options.page
        offset: @_computeOffset()
      )

    _refreshPagerText: ->
      @_pagerText.text("Página #{@options.page} de #{@_totalPages}")

    _computeOffset: ->
      @options.max * (@options.page - 1)

    _nextPagerClicked: (e) ->
      if @options.page < @_totalPages
        @options.page = @options.page + 1
        @_refreshPagerText()
        @_triggerChangePageEvent(e)

    _pagerClicked: (e) ->
      $pagerLink = $(e.currentTarget)
      @options.page = $pagerLink.data('_id')
      @_refreshPagerText()
      @_triggerChangePageEvent(e)

    _refresh: ->
      @_refreshPaginator()
      @_refreshPreviousPager()
      @_refreshNextPager()
      @_refreshPagers()

    _refreshPaginator: ->
      fn = 'hide'
      fn = 'show' if @_isTotalValid() and @_areThereSeveralPages()
      @element[fn]()

    _isTotalValid: ->
      total = @options.total
      typeof total is 'number' and total > 0

    _areThereSeveralPages: ->
      @_totalPages > 1

    _refreshPreviousPager: ->
      visibility = 'visible'
      visibility = 'hidden' if @_isFirstPage()
      @_$previousPager.css('visibility', visibility)

    _isFirstPage: ->
      @options.page is 1

    _refreshNextPager: ->
      visibility = 'visible'
      visibility = 'hidden' if @_isLastPage()
      @_$nextPager.css('visibility', visibility)

    _isLastPage: ->
      @options.page is @_totalPages

    _refreshPagers: ->
      @_refreshHeadPagers()
      @_refreshTailPagers()
      @_refreshEllipsisPager()

    _refreshHeadPagers: ->
      @_refreshPagersRange(@_$headPagers, @_getHeadPageRange())

    _refreshPagersRange: ($pagers, pages) ->
      $pagers.each (index, pager) ->
        page = pages[index]
        text = ''
        fn = 'hide'
        if page?
          text = page.toString()
          fn = 'show'
        $(pager).data('_page', page)[fn]().find('a').text(text)

    _getHeadPageRange: ->
      startPage = 1
      endPage = Math.min(@_totalPages, @_getMiddleIndex())
      [startPage..endPage]

    _refreshTailPagers: ->
      @_refreshPagersRange(@_$tailPagers, @_getTailPageRange())

    _getTailPageRange: ->
      middleIndex = @_getMiddleIndex()
      if @_totalPages > middleIndex
        startPage = middleIndex + 1
        endPage = @_totalPages
        if @_totalPages > @_MAX_PAGES
          startPage = @_totalPages - middleIndex + 1
        [startPage..endPage]
      else
        []

    _refreshEllipsisPager: ->
      fn = 'hide'
      fn = 'show' if @_totalPages > @_MAX_PAGES
      @_$ellipsisPager[fn]()
)(jQuery)
