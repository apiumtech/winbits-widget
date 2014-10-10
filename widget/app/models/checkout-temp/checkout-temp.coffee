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
    @get('total')

  orderTotal: ->
    @sliderTotal() - @get('bitsTotal')

  itemsFullTotal: ->
    priceTotal = 0
    orderDetails = @get('orderDetails')
    if orderDetails
      priceTotal += (d.quantity * d.sku.fullPrice) for d in orderDetails
    priceTotal

  orderSaving: ->
    (@itemsFullTotal() - @orderTotal()).toFixed(2)

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

  updateOrder:(formData, options) ->
    defaults =
      type: "PUT"
      data: JSON.stringify(formData)
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(
        utils.getResourceURL("orders/orders/#{formData.id}.json"),
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

