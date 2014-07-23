'use strict'
utils = require 'lib/utils'
Model = require "models/cart/cart"
env = Winbits.env
$ = Winbits.$

module.exports = class CheckoutTemp extends Model

  accessors:[
    'sliderTotal',
    'orderTotal',
    'orderSaving',
    'itemsFullTotal'
  ]
  sliderTotal: ->
    @get('itemsTotal') + @get('shippingTotal')

  orderTotal: ->
    @sliderTotal() - @get('bitsTotal')

  itemsFullTotal: ->
    priceTotal = 0
    orderDetails = @get('orderDetails')
    if orderDetails
      priceTotal += (d.quantity * d.sku.fullPrice) for d in orderDetails
    priceTotal

  orderSaving: ->
    @itemsFullTotal() - @orderTotal()

  deleteOrderDetail:(formData, options) ->
    defaults =
      type: "DELETE"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(
        utils.getResourceURL("orders/order-items/#{formData.id}"),
        $.extend(defaults, options)
    )

  cancelOrder:(options) ->
      defaults =
        type: "DELETE"
        headers:
          "Accept-Language": "es"
          "WB-Api-Token": utils.getApiToken()
      utils.ajaxRequest(
          utils.getResourceURL("orders/orders/#{@get('id')}.json"),
          $.extend(defaults, options)
      )

