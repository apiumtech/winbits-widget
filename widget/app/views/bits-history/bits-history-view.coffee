'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
BitsHistoryTableView = require 'views/bits-history/bits-history-table-view'
HistoryHeaderView = require 'views/account-history/history-header-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class BitsHistoryView extends View
  container: env.get('vertical-container')
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/bits-history'
  params:
    max: 20

  initialize:()->
    super
    @model.fetch data: @params, context: @, success: @render
    $loginData = mediator.data.get 'login-data'
    @model.set 'bitsTotal', $loginData.bitsBalance
    @model.set 'pendingOrderCount', $loginData.profile.pendingOrdersCount
    @delegate 'click', '#wbi-your-bits-history-btn-back', @backToVertical
    $('#wbi-my-account-div').slideUp()
    utils.replaceVerticalContent('.widgetWinbitsMain')
    @subscribeEvent 'bits-history-params-changed', @paramsChanged

  attach: ->
    super
    @$('.select').customSelect()
    @$('.wbc-paginator').wbpaginator(total: @model.getTotalTransactions(), max: @params.max, change: $.proxy(@pageChanged, @))
    @$('#wbi-account-bits-total-link').hide()

  paramsChanged: (params)->
    $.extend(@params, params)
    @updateHistory()

  pageChanged: (e, ui) ->
    params = max: ui.max, offset: ui.offset
    @paramsChanged(params)

  updateHistory: ->
    @model.fetch {data:@params}

  backToVertical:()->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview('bits-history-table-view', new BitsHistoryTableView model: @model)
    @subview('history-header-view', new HistoryHeaderView model: @model)
