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

  requestCouponsService:(orderDetailId, options)->
    defaults =
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(
      env.get('api-url') + "/users/coupons/#{orderDetailId}.json",
      $.extend(defaults, options)
    )

