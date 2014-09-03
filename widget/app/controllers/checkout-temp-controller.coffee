'use strict'
LoggedInController = require 'controllers/logged-in-controller'
CheckoutTempView = require 'views/checkout-temp/checkout-temp-view'
CheckoutTemp = require 'models/checkout-temp/checkout-temp'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class CheckoutController extends LoggedInController

  index: (params)->
    unless($.isEmptyObject(params))
      for orderDetail in params.orderDetails
        orderDetail.max = orderDetail.quantity
      @model = new CheckoutTemp params
      @view = new CheckoutTempView  model: @model
    else
      utils.redirectToLoggedInHome()