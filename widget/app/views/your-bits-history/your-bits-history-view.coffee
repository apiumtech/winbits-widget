'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
BitsTableView = require 'views/your-bits-history/bits-table-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class YourBitsHistoryView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/your-bits-history'
  params:
    max: 20

  initialize:()->
    super
    @model.fetch data:@params, success: $.proxy(@render, @)
    @delegate 'click', '#wbi-your-bits-history-btn-back', @backToVertical
    $('#wbi-my-account-div').slideUp()
    $('main .wrapper').hide()
    $('main .widgetWinbitsMain').show()
    @subscribeEvent 'bits-history-params-changed', @paramsChanged

  attach:()->
    super
    @$('.select').customSelect()
    @$('.wbc-paginator').wbpaginator(total: @model.getTotalTransactions(), max: @params.max, change: $.proxy(@pageChanged, @))

  paramsChanged: (params)->
    $.extend(@params, params)
    @model.fetch {data:@params}

  backToVertical:()->
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  pageChanged: (e, ui) ->
    params = max: ui.max, offset: ui.offset
    @updateParams(params)

  updateParams: (params) ->
    $.extend(@params, params)
    @model.fetch(data: @params)

  render: ()->
    super
    @subview('bits-table-view', new BitsTableView model: @model)