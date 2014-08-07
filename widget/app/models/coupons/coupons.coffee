utils = require 'lib/utils'
Model = require "models/base/model"
env = Winbits.env
$ = Winbits.$

module.exports = class Coupon extends Model

  initialize: ->
    super

  doRequestCouponService: (couponId,orderDetailId,format, options)->
    defaults =
      contentType: "application/json"
      dataType: "json"
      headers:
        "Accept-Language": "es"
        "WB-Api-Token": utils.getApiToken()
    utils.ajaxRequest(
      env.get('api-url') + "/users/coupon/#{couponId}.json?format=#{format}&orderDetailId=#{orderDetailId}",
      $.extend(defaults, options)
    )
