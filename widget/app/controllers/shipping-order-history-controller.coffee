'use strict'
LoggedInController = require 'controllers/logged-in-controller'
ShippingOrderHistoryView = require 'views/shipping-order/shipping-order-history-view'
ShippingOrderHistory = require 'models/shipping-order/shipping-order-history'
utils = require 'lib/utils'

module.exports = class ShippingOrderHistoryController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    @model = new ShippingOrderHistory
    @view = new ShippingOrderHistoryView  model: @model