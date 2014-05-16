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

)(jQuery)
