'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
BitsTableView = require './bits-table-view'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class HistoryView extends View
  container: 'main'
  className: 'widgetWinbitsMain'
  template: require './templates/your-bits-history'
  params:
    max: 20

  initialize:()->
    super
    @listenTo @model, 'change:transactions', @refreshHistory
    @model.fetch(@params)
    @delegate 'click', '#wbi-your-bits-history-btn-back', @backToVertical
    $('#wbi-my-account-div').slideUp()
    $('main .wrapper').hide()
    $('main .widgetWinbitsMain').show()
    @subscribeEvent 'bits-history-params-changed', @paramsChanged

  paramsChanged: (params)->
    $.extend(@params, params)
    @model.fetch(@params)

  render: ->
    super
    @subview('bits-table-view', new BitsTableView model: @model)

  backToVertical:()->
    $('main .wrapper').show()
    utils.redirectToLoggedInHome()

  pageChanged: (e, ui) ->
    console.log('Page changed')
    @updateParams(max: ui.max, offset: ui.offset)

  updateParams: (params) ->
    $.extend(@params, params)
    @model.fetch(data: @params)

  refreshHistory: ->
    @render()
    @$('.wbc-paginator').wbpaginator('option', 'total', @model.getTotalTransactions())