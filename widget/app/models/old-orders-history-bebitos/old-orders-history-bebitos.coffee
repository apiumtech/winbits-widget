'use strict'
utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$
_ = Winbits._

module.exports = class OldOrdersHistoryBebitos extends Model
  url: env.get('api-url') + "/users/orders.json"
  needsAuth: true

  parse: (data) ->
    orders: super

  getOrderWithCoupon:(numberOrder, detailId) ->
    order = _.find(@get("orders"),(order) -> numberOrder is order.orderNumber)
    _.find(order.skus,(sku)-> detailId is sku.orderDetailId)