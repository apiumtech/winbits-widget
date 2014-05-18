'use strict'

(($) ->
  $.widget 'winbits.wbpaginator',
    _MAX_PAGES: 10

    options:
      max: 10
      page: 1

    _create: ->
      @_setOption('total', @options.total)
      @_setOption('max', @options.max)
      @_updateTotalPages()
      @_setOption('page', @options.page)
      @_pager = @_generatePager()
      @_pagersList = @_generatePagersList()
      @_previousPager = @_generatePreviousPagePager()
      @_pagers = @_generatePagers()
      @_nextPager = @_generateNextPagePager()
      @_bindPagersEvents()

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

    _generatePager: ->
      page = @options.page
      $('<p></p>', class: 'wbc-pager-text').text("Página #{page} de #{@_totalPages}").appendTo(@element)

    _generatePagersList: ->
      $('<ul></ul>', class: 'wbc-pagers').appendTo(@element)

    _generatePagers: ->
      for page in @_getPagesRange()
        $pager = $('<li></li>', class: 'wbc-pager')
        $('<a></a>', href: '#', class: 'wbc-pager-link').text(page).data('_id', page).appendTo($pager)
        @_pagersList.append($pager)
      $pagers = @_pagersList.children()
      if @_totalPages > @_MAX_PAGES
        @_generateEllipsisPager()
      $pagers

    _getPagesRange: ->
      if @_totalPages > @_MAX_PAGES
        halfRangeSize = Math.floor(@_MAX_PAGES / 2)
        [1..halfRangeSize].concat([(@_totalPages - halfRangeSize + 1)..@_totalPages])
      else
        [1..@_totalPages]

    _generateEllipsisPager: ->
      middleIndex = Math.floor(@_MAX_PAGES / 2)
      $pagerEllipsis = $('<li></li>', class: 'wbc-pager-ellipsis')
      $('<a></a>', href: '#').text('...').appendTo($pagerEllipsis)
      @_pagersList.children().eq(middleIndex).before($pagerEllipsis)

    _generatePreviousPagePager: ->
      $previousPager = $('<li></li>', class: 'wbc-previous-pager pager-prev')
      $previousPagerLink = $('<a></a>', href: '#', class: 'wbc-previous-pager-link').text(' Ant').appendTo($previousPager)
      $('<span></span>', class: 'iconFont-arrowLeft').appendTo($previousPagerLink)
      $previousPager.prependTo(@_pagersList)

    _generateNextPagePager: ->
      $nextPager = $('<li></li>', class: 'wbc-next-pager pager-next')
      $nextPagerLink = $('<a></a>', href: '#', class: 'wbc-next-pager-link').text('Sig ').appendTo($nextPager)
      $('<span></span>', class: 'iconFont-arrowRight').appendTo($nextPagerLink)
      $nextPager.appendTo(@_pagersList)

    _bindPagersEvents: ->
      @_pagersList.on('click', 'a', (e) -> e.preventDefault())
      @_pagersList.on('click', 'a.wbc-previous-pager-link', $.proxy(@_previousPagerLinkClicked, @))
      @_pagersList.on('click', 'a.wbc-next-pager-link', $.proxy(@_nextPagerLinkClicked, @))
      @_pagersList.on('click', 'a.wbc-pager-link', $.proxy(@_pagerLinkClicked, @))

    _previousPagerLinkClicked: (e) ->
      if @options.page > 1
        @options.page = @options.page - 1
        @_refreshPager()
        @_triggerChangePageEvent(e)

    _triggerChangePageEvent: (e) ->
      @_trigger('change', e,
        total: @options.total
        max: @options.max
        page: @options.page
        offset: @_computeOffset()
      )

    _refreshPager: ->
      @_pager.text("Página #{@options.page} de #{@_totalPages}")

    _computeOffset: ->
      @options.max * (@options.page - 1)

    _nextPagerLinkClicked: (e) ->
      if @options.page < @_totalPages
        @options.page = @options.page + 1
        @_refreshPager()
        @_triggerChangePageEvent(e)

    _pagerLinkClicked: (e) ->
      $pagerLink = $(e.currentTarget)
      @options.page = $pagerLink.data('_id')
      @_refreshPager()
      @_triggerChangePageEvent(e)
)(jQuery)
