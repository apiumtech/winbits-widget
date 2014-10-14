'use strict'
OldOrdersHitoryController = require 'controllers/old-orders-history-controller'
OldCouponsModalView = require 'views/old-orders-coupons/old-orders-coupons-view'
OldCoupons = require 'models/old-orders-coupons/old-orders-coupons'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class OldOrdersCouponsController extends OldOrdersHitoryController

  beforeAction: ->
    super

  index:->
    console.log 'old-orders-coupon#index'
    couponData = mediator.data.get('old-coupon-data')
    if couponData
      @model = new OldCoupons(couponData)
      @view = new OldCouponsModalView model: @model
    else
      utils.redirectTo url: '/#wb-old-orders-history'
