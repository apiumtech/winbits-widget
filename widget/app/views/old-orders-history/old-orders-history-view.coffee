'use strict'

View = require 'views/base/view'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator
$ = Winbits.$
env = Winbits.env
mediator = Winbits.Chaplin.mediator

module.exports = class OldOrdersHistoryView extends View
  container: env.get('vertical-container')
  className: 'widgetWinbitsMain wbc-vertical-content'
  template: require './templates/old-orders-history'
  params:
    max:10

  initialize:()->
    super
    $('#wbi-my-account-div').slideUp()
    @delegate 'click', '#wbi-shipping-order-link', @redirectToShippingOrderHistory
    @delegate 'click', '#wbi-shipping-order-link-text', @redirectToShippingOrderHistory
    @delegate 'click', '#wbi-old-orders-history-btn-back', @backToVertical
    @delegate 'click', '.wbc-old-orders-coupons', @findAndRedirectCoupon
    utils.replaceVerticalContent('.widgetWinbitsMain')

  attach: ->
    super
    @$('.select').customSelect()
      .wbpaginator(total: @model.getTotal(), max: @params.max, change: $.proxy(@pageChanged, @))

  redirectToShippingOrderHistory: (e)->
    e.preventDefault()
    utils.redirectTo(controller: 'shipping-order-history')

  backToVertical:(e)->
    utils.restoreVerticalContent('.widgetWinbitsMain')
    utils.redirectToLoggedInHome()

  findAndRedirectCoupon:(e)->
    e.preventDefault()
    orderNumber = $(e.currentTarget).data('ordernumber')
    detailId = $(e.currentTarget).data('detailid')
    console.log ["Order number", orderNumber]
    order = @model.getOrderWithCoupon(orderNumber, detailId)
    console.log ["Order", order]
    mediator.data.set 'old-coupon-data', order
    utils.redirectTo url: '/#wb-old-orders-coupon'

