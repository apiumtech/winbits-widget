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
    @get('itemsTotal') - @get('bitsTotal')

  orderTotal: ->
    @sliderTotal() + @get('bitsTotal')

  itemsFullTotal: ->
    priceTotal = 0
    orderDetails = @get('orderDetails')
    if orderDetails
      priceTotal += (d.quantity * d.sku.fullPrice) for d in orderDetails
    priceTotal

  orderSaving: ->
    @itemsFullTotal() - @orderTotal()

