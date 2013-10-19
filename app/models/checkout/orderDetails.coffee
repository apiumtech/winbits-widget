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
#    bitsBalance = bitsBalance || mediator.profile.bitsBalance
    bitsBalance = bitsBalance || parseFloat(window.bits_balance)
    model = {}
    model.orderId = order.id
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

  updateOrderBits: (bits) ->
    updateData = {bitsTotal: bits, orderId: @get('orderId') }
    Backbone.$.ajax config.apiUrl + "/orders/update-order-bits.json",
      type: "PUT"
      contentType: "application/json"
      dataType: "json"
      data: JSON.stringify(updateData)
      context: @
      headers:
        "Accept-Language": "es"
        "WB-Api-Token":  util.getCookie(config.apiTokenName)

      success: (data) ->
        console.log ["Success: Update cart bits", data.response]
        @set @completeOrderModel(data.response)
        @publishEvent('orderBitsUpdated', data.response)
        if data.response.cashTotal is 0 
            @publishEvent('showBitsPayment')


      error: (xhr, textStatus, errorThrown) ->
        util.showAjaxError(xhr.responseText)
