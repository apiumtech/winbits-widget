ChaplinModel = require 'chaplin/models/model'
config = require 'config'
util = require 'lib/util'
mediator = require 'chaplin/mediator'
module.exports = class OrderDetails extends ChaplinModel

  initialize: (attributes, option) ->
    super
    console.log ['Order Details Init', attributes, option, mediator.order_post]

  parse: (response) ->
    console.log ['Order Details Parse', response]
    response

  completeOrderModel: (order, bitsBalance) ->
    bitsBalance = bitsBalance || mediator.profile.bitsBalance
    model = {}
    model.orderDetails = order.orderDetails
    model.bitsTotal = order.bitsTotal
    model.shippingTotal = order.shippingTotal
    model.total = order.total
    model.cashTotal = order.cashTotal
    model.itemsTotal = order.itemsTotal
    orderFullPrice = util.calculateOrderFullPrice(order.orderDetails)
    model.orderFullPrice = orderFullPrice
    model.orderSaving = orderFullPrice - order.itemsTotal
    model.maxBits = Math.min(order.total, bitsBalance)
    model