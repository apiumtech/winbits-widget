'use strict'
LoggedInController = require 'controllers/logged-in-controller'
ShippingOrderHistoryView = require 'views/shipping-order/shipping-order-history-view'
ShippingOrderHistory = require 'models/shipping-order/shipping-order-history'
utils = require 'lib/utils'

module.exports = class ShippingOrderHistoryController extends LoggedInController

  beforeAction: ->
    super
    @reuse 'shipping-orders-history',
      compose: ->
        @model = new ShippingOrderHistory
        @view = new ShippingOrderHistoryView  model: @model

  index: ->
    console.log ["shipping-orders-history#index"]
