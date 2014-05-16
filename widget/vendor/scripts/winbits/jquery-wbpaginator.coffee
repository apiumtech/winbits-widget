'use strict'

(($) ->
  $.widget 'winbits.wbpaginator',
    options:
      max: 10
      page: 1

    _create: ->
      @options.total = @_constrainTotal(@options.total)
      @options.max = @_constrainMax(@options.max)
      @options.page = @_constrainPage(@options.page)
      @_pager = @_generatePager()
      @_pageList = @_generatePageList()
      @_previousPager = @_generatePreviousPagePager()
      @_pages = @_generatePages()
      @_nextPager = @_generateNextPagePager()

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
      Math.floor(@options.total / @options.max)

    _generatePager: ->
      page = @options.page
      totalPages = @_totalPages()
      $('<p></p>', class: 'wbc-pager').text("Página #{page} de #{totalPages}").appendTo(@element)

    _generatePageList: ->
      $('<ul></ul>', class: 'wbc-pages').appendTo(@element)

    _generatePages: ->
      totalPages = @_totalPages()
      pages = []
      for page in [1..totalPages]
        pages.push "<li class='wbc-page'><a href='#' class='wbc-page-link'>#{page}</a></li>"
      @_pageList.append(pages.join(''))
      @_pageList.children()

    _generatePreviousPagePager: ->
      $previousPager = $('<li></li>', class: 'wbc-previous-pager pager-prev')
      $previousPagerLink = $('<a></a>', href: '#', class: 'wbc-previous-pager-link').text(' Ant').appendTo($previousPager)
      $('<span></span>', class: 'iconFont-arrowLeft').appendTo($previousPagerLink)
      $previousPager.prependTo(@_pageList)

    _generateNextPagePager: ->
      $nextPager = $('<li></li>', class: 'wbc-next-pager pager-next')
      $nextPagerLink = $('<a></a>', href: '#', class: 'wbc-next-pager-link').text('Sig ').appendTo($nextPager)
      $('<span></span>', class: 'iconFont-arrowRight').appendTo($nextPagerLink)
      $nextPager.appendTo(@_pageList)

)(jQuery)
