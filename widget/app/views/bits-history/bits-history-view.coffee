'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
BitsHistoryTableView = require 'views/bits-history/bits-history-table-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class BitsHistoryView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/bits-history'
  params:
    max: 20

  initialize:()->
    super
    @model.fetch data: @params, context: @, success: @render
    @delegate 'click', '#wbi-your-bits-history-btn-back', @backToVertical
    $('#wbi-my-account-div').slideUp()
    $('main .wrapper').hide()
    $('main .widgetWinbitsMain').show()
    @subscribeEvent 'bits-history-params-changed', @paramsChanged

  attach: ->
    super
    @$('.select').customSelect()
    @$('.wbc-paginator').wbpaginator(total: @model.getTotalTransactions(), max: @params.max, change: $.proxy(@pageChanged, @))

  paramsChanged: (params)->
    $.extend(@params, params)
    @updateHistory()

  pageChanged: (e, ui) ->
    params = max: ui.max, offset: ui.offset
    @paramsChanged(params)

  updateHistory: ->
    @model.fetch {data:@params}

  backToVertical:()->
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview('bits-history-table-view', new BitsHistoryTableView model: @model)
