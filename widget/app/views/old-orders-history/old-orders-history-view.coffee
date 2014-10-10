'use strict'

View = require 'views/base/view'
OldOrdersSubview = require 'views/old-orders-history/old-orders-history-table-subview'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class OldOrdersHistoryView extends View
  container: env.get('vertical-container')
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/old-orders-history'
  params:
    max:10

  initialize:()->
    super
    @model.fetch data:@params, success: $.proxy(@render, @)
    @delegate 'click', '#wbi-shipping-order-link', @redirectToShippingOrderHistory
    @delegate 'click', '#wbi-shipping-order-link-text', @redirectToShippingOrderHistory

    $('#wbi-my-account-div').slideUp()
    utils.replaceVerticalContent('.widgetWinbitsMain')
    @subscribeEvent 'shipping-order-history-params-changed', @paramsChanged

  attach: ->
    super
    @$('.select').customSelect()
      .wbpaginator(total: @model.getTotal(), max: @params.max, change: $.proxy(@pageChanged, @))


  paramsChanged: (params)->
    $.extend @params, params
    @updateHistory()

  pageChanged: (e, ui) ->
    params = max: ui.max, offset: ui.offset
    @paramsChanged params

  updateHistory: ->
    @model.fetch {data:@params}

  redirectToShippingOrderHistory: (e)->
    e.preventDefault()
    utils.redirectTo(controller: 'shipping-order-history')

  render: ()->
    super
    @subview 'old-orders-history-table', new OldOrdersSubview model:@model