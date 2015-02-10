'use strict'
LoggedInController = require 'controllers/logged-in-controller'
OldOrdersHistoryBebitosView = require 'views/old-orders-history-bebitos/old-orders-history-bebitos-view'
OldOrdersHistoryBebitos = require 'models/old-orders-history-bebitos/old-orders-history-bebitos'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class OldOrdersHistoryBebitosController extends LoggedInController

  beforeAction: ->
    super

  index: ->
    console.log ["old-orders-history-bebitos-view"]
    if mediator.data.get 'old-orders-bebitos'
      console.log ["Si hay bebito-old-orders"]
      $loginData = mediator.data.get 'login-data'
      @model=new OldOrdersHistoryBebitos(orders: mediator.data.get 'old-orders-bebitos')
      @model.set 'pendingOrderCount', $loginData.profile.pendingOrdersCount
      @model.set 'bitsTotal', $loginData.bitsBalance
      @view=new OldOrdersHistoryBebitosView  model: @model
    else
      utils.redirectTo controller: 'shipping-order-history', action:'index'