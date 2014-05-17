'use strict'

(($) ->
  $.widget 'winbits.wbpaginator',
    options:
      max: 10
      page: 1

    _MAX_PAGES: 10

    _create: ->
      @options.total = @_constrainTotal(@options.total)
      @options.max = @_constrainMax(@options.max)
      @options.page = @_constrainPage(@options.page)
      @_pager = @_generatePager()
      @_pagersList = @_generatePagersList()
      @_previousPager = @_generatePreviousPagePager()
      @_pagers = @_generatePagers()
      @_nextPager = @_generateNextPagePager()
      @_bindPagersEvents()

    _constrainTotal: (total) ->
      if typeof total is 'number'
        Math.ceil(total)

    _constrainMax: (max) ->
      if typeof max is 'number' and max >= 1 and max <= @options.total
        Math.ceil(max)
      else
        10

    _constrainPage: (page) ->
      totalPages = @_totalPages()
      if typeof page is 'number' and page >= 1 and page <= totalPages
        Math.ceil(page)
      else
        1

    _totalPages: ->
      Math.ceil(@options.total / @options.max)

    _generatePager: ->
      page = @options.page
      totalPages = @_totalPages()
      $('<p></p>', class: 'wbc-pager-text').text("Página #{page} de #{totalPages}").appendTo(@element)

    _generatePagersList: ->
      $('<ul></ul>', class: 'wbc-pagers').appendTo(@element)

    _generatePagers: ->
      for page in @_getPagesRange()
        $pager = $('<li></li>', class: 'wbc-pager')
        $('<a></a>', href: '#', class: 'wbc-pager-link').text(page).data('_id', page).appendTo($pager)
        @_pagersList.append($pager)
      $pagers = @_pagersList.children()
      if @_totalPages() > @_MAX_PAGES
        @_generateEllipsisPager()
      $pagers

    _getPagesRange: ->
      totalPages = @_totalPages()
      if totalPages > @_MAX_PAGES
        halfRangeSize = Math.floor(@_MAX_PAGES / 2)
        [1..halfRangeSize].concat([(totalPages - halfRangeSize + 1)..totalPages])
      else
        [1..totalPages]

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
        @_trigger('change', e, total: @options.total, max: @options.max, page: @options.page, offset: @_offset())

    _refreshPager: ->
      @_pager.text("Página #{@options.page} de #{@_totalPages()}")

    _offset: ->
      @options.max * (@options.page - 1)

    _nextPagerLinkClicked: (e) ->
      if @options.page < @_totalPages()
        @options.page = @options.page + 1
        @_refreshPager()
        @_trigger('change', e, total: @options.total, max: @options.max, page: @options.page, offset: @_offset())

    _pagerLinkClicked: (e) ->
      $pagerLink = $(e.currentTarget)
      @options.page = $pagerLink.data('_id')
      @_refreshPager()
      @_trigger('change', e, total: @options.total, max: @options.max, page: @options.page, offset: @_offset())
)(jQuery)
