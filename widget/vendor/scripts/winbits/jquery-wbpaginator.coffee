'use strict'

(($) ->
  $.widget 'winbits.wbpaginator',
    _MAX_PAGES: 11
    _ELLIPSIS_RANGE_LENGTH: 2
    _CURRENT_PAGE_CLASS: 'wbc-current-page'
    _ELLIPSIS_PAGER_CLASS: 'wbc-ellipsis-pager'

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
        .appendTo(@element)

    _createPagersList: ->
      @_$pagersList = $('<ul></ul>', class: 'wbc-pagers').appendTo(@element)
      @_createPagers()

    _createPagers: ->
      @_createNumberPagers()
      @_createEllipsisPagers()
      @_createPreviousPagePager()
      @_createNextPagePager()

    _createNumberPagers: ->
      pagers = (@_createPager().get(0) for i in [1..@_MAX_PAGES])
      @_$numberPagers = $(pagers).appendTo(@_$pagersList)
      @_$headPagers = @_$numberPagers.slice(0, @_ELLIPSIS_RANGE_LENGTH)
      @_$middlePagers = @_$numberPagers
        .slice(@_ELLIPSIS_RANGE_LENGTH, -@_ELLIPSIS_RANGE_LENGTH)
      @_$tailPagers = @_$numberPagers.slice(-@_ELLIPSIS_RANGE_LENGTH)


    _getMiddleIndex: ->
      Math.floor(@_MAX_PAGES / 2)

    _createPager: (pagerClass = 'wbc-pager') ->
      $('<li></li>', class: pagerClass)
        .append($('<a></a>', href: '#'))

    _createEllipsisPagers: ->
      @_$leftEllipsisPager = @_createPager(@_ELLIPSIS_PAGER_CLASS)
        .insertBefore(@_$middlePagers.first())
      @_$rightEllipsisPager = @_createPager(@_ELLIPSIS_PAGER_CLASS)
        .insertAfter(@_$middlePagers.last())
      @_$ellipsisPagers = @_$leftEllipsisPager.add(@_$rightEllipsisPager)
      @_$ellipsisPagers.find('a').text('...')

    _createPreviousPagePager: ->
      @_$previousPager = $('<li></li>', class: 'wbc-previous-pager pager-prev')
      $pagerLink = $('<a></a>', href: '#')
        .text(' Ant')
        .appendTo(@_$previousPager)
      $('<span></span>', class: 'iconFont-arrowLeft').prependTo($pagerLink)
      @_$previousPager.prependTo(@_$pagersList)

    _createNextPagePager: ->
      @_$nextPager = $('<li></li>', class: 'wbc-next-pager pager-next')
      $pagerLink = $('<a></a>', href: '#')
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
        @_changeToPage(@options.page - 1, e)

    _changeToPage: (newPage, e) ->
      @options.page = newPage
      @_refresh()
      @_triggerChangePageEvent(e)

    _triggerChangePageEvent: (e) ->
      @_trigger('change', e,
        total: @options.total
        max: @options.max
        page: @options.page
        offset: @_computeOffset()
      )

    _nextPagerClicked: (e) ->
      if @options.page < @_totalPages
        @_changeToPage(@options.page + 1, e)

    _pagerClicked: (e) ->
      $pager = $(e.currentTarget)
      page = $pager.data('_page')
      if not @_isCurrentPage(page)
        @_changeToPage(page, e)

    _isCurrentPage: (page) ->
      @_$currentPage? and @_$currentPage.data('_page') is page

    _refresh: ->
      @_refreshPaginator()
      @_refreshPagers()
      @_refreshCurrentPage()

    _refreshPaginator: ->
      @_showOrHideIf(@element, @_isPaginatorVisible())

    _isPaginatorVisible: ->
      @_isTotalValid() and @_areThereSeveralPages()

    _isTotalValid: ->
      total = @options.total
      typeof total is 'number' and total > 0

    _areThereSeveralPages: ->
      @_totalPages > 1

    _refreshPagers: ->
      @_refreshNavigationPagers()
      @_refreshEllipsisPagers()
      @_refreshNumberPagers()

    _refreshNumberPagers: ->
      pages = @_getPages()
      @_refreshPagersRange(@_$numberPagers, pages)

    _getPages: ->
      if not @_hasMoreThanMaxPages()
        [1..@_totalPages]
      else if @_isCurrentPageInFirstRange()
        [1..9].concat(@_getTailPages(@_ELLIPSIS_RANGE_LENGTH))
      else if @_isCurrentPageInLastRange()
        [1..2].concat(@_getTailPages(@_MAX_PAGES - @_ELLIPSIS_RANGE_LENGTH))
      else
        tailPages = @_getTailPages(@_ELLIPSIS_RANGE_LENGTH)
        [1..2].concat(@_getPagesCenteredOn(@options.page)).concat(tailPages)

    _hasMoreThanMaxPages: ->
      @_totalPages > @_MAX_PAGES

    _isCurrentPageInFirstRange: ->
      @options.page <= 6

    _isCurrentPageInLastRange: ->
      @options.page > @_totalPages - 6

    _getTailPages: (number) ->
      startPage = @_totalPages - number + 1
      [startPage..@_totalPages]

    _getPagesCenteredOn: (centralPage) ->
      offset = 3
      [(centralPage - offset)..centralPage]
        .concat([(centralPage + 1)..(centralPage + offset)])

    _refreshPagersRange: ($pagers, pages) ->
      $pagers.each (index, pager) ->
        page = pages[index]
        text = ''
        fn = 'hide'
        if page?
          text = page.toString()
          fn = 'show'
        $(pager).data('_page', page)[fn]().find('a').text(text)

    _refreshEllipsisPagers: ->
      @_refreshLeftEllipsisPager()
      @_refreshRightEllipsisPager()

    _refreshLeftEllipsisPager: ->
      @_showOrHideIf(@_$leftEllipsisPager, @_isLeftEllipsisPagerVisible())

    _isLeftEllipsisPagerVisible: ->
      @_hasMoreThanMaxPages() and not @_isCurrentPageInFirstRange()

    _showOrHideIf: ($elements, visible) ->
      fn = if visible then 'show' else 'hide'
      $elements[fn]()

    _refreshRightEllipsisPager: ->
      @_showOrHideIf(@_$rightEllipsisPager, @_isRightEllipsisPagerVisible())

    _isRightEllipsisPagerVisible: ->
      @_hasMoreThanMaxPages() and not @_isCurrentPageInLastRange()

    _refreshNavigationPagers: ->
      @_refreshPreviousPager()
      @_refreshNextPager()

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

    _refreshCurrentPage: ->
      page = @options.page
      @_refreshPagerText()
      @_$numberPagers.removeClass(@_CURRENT_PAGE_CLASS)
      @_$currentPage = @_$numberPagers.filter () ->
        $(@).data('_page') is page
      @_$currentPage.addClass(@_CURRENT_PAGE_CLASS)

    _refreshPagerText: ->
      @_pagerText.text("Página #{@options.page} de #{@_totalPages}")

    _computeOffset: ->
      @options.max * (@options.page - 1)
)(jQuery)
