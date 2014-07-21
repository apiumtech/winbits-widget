'use strict'

View = require 'views/base/view'
ShippingOrderSubview = require 'views/shipping-order/shipping-order-history-table-subview'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env

module.exports = class ShippingOrderHistoryView extends View
  container: env.get('vertical-container')
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/shipping-order-history'
  params:
    max:10


  initialize:()->
    super
    @model.fetch data:@params, success: $.proxy(@render, @)
    @delegate 'click', '#wbi-shipping-order-history-btn-back', @backToVertical
    @delegate 'click', '.wbc-icon-coupon', @requestCouponService
    $('#wbi-my-account-div').slideUp()
    utils.replaceVerticalContent('.widgetWinbitsMain')
    @subscribeEvent 'shipping-order-history-params-changed', @paramsChanged

  attach: ->
    super
    @$('.select').customSelect()
    @$('#wbi-shipping-order-history-paginator').wbpaginator(total: @model.getTotal(), max: @params.max, change: $.proxy(@pageChanged, @))

  paramsChanged: (params)->
    $.extend @params, params
    @updateHistory()

  pageChanged: (e, ui) ->
    params = max: ui.max, offset: ui.offset
    @paramsChanged params

  updateHistory: ->
    @model.fetch {data:@params}

  requestCouponService:(e)->
    dataOrderDetailNumber = @$(e.currentTarget).closest('.wbc-order-detail').data('id')
    utils.showLoaderToCheckout()
    @model.requestCouponsService(dataOrderDetailNumber, @)
      .done((data)-> console.log ["data success", data])
      .fail( (xhr) -> console.log ["error data", xhr.responseText])
      .always(-> utils.hideLoaderToCheckout())

  backToVertical:()->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    utils.redirectToLoggedInHome()

  render: ()->
    super
    @subview 'shipping-order-history-table', new ShippingOrderSubview model:@model
