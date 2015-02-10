'use strict'
LoggedInController = require 'controllers/logged-in-controller'
OldOrdersHistoryView = require 'views/old-orders-history/old-orders-history-view'
OldOrdersHistory = require 'models/old-orders-history/old-orders-history'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class OldOrdersHistoryController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    console.log ["old-orders-view"]
    if mediator.data.get 'old-orders'
      console.log ["Si hay old-orders"]
      $loginData = mediator.data.get 'login-data'
      @model=new OldOrdersHistory(orders: mediator.data.get 'old-orders')
      @model.set 'pendingOrderCount', $loginData.profile.pendingOrdersCount
      @model.set 'bitsTotal', $loginData.bitsBalance
      @view=new OldOrdersHistoryView  model: @model
    else
      utils.redirectTo controller: 'shipping-order-history', action:'index'