'use strict'

(($) ->
  $.widget 'winbits.wbpaginator',
    options:
      max: 10
      page: 1

    _create: ->
      @options.max = @_constrainMax(@options.max)
      @options.page = @_constrainPage(@options.page)

    _constrainMax: (max) ->
      if max in [1..@options.total] then max else 10

    _constrainPage: (page) ->
      totalPages = @_totalPages()
      if page in [1..totalPages] then page else 1

    _totalPages: ->
      Math.floor(@options.total / @options.max)

)(jQuery)
