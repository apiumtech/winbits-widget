'use strict'
utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class ShippingOrderHistory extends Model
  url: env.get('api-url') + "/users/orders.json"
  needsAuth: true

  parse: (data) ->
    orders: super

  getTotal: ->
    if (@meta)
      @meta.totalCount
    else
      0

  requestCouponsService:()->
    console.log ["REQUEST COUPONS SERVICE IN MODEL"]
