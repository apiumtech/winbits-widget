LoggedInController = require 'controllers/logged-in-controller'
CouponsModalView = require 'views/coupons/coupons-view'
Coupons = require 'models/coupons/coupons'
utils = require 'lib/utils'
mediator = Winbits.Chaplin.mediator

module.exports = class CouponController extends LoggedInController

  beforeAction: ->
    super

  index:->
    console.log 'coupon#index'
    couponData = mediator.data.get('coupon-data')
    if couponData
      @model = new Coupons(mediator.data.get('coupon-data'))
      @view = new CouponsModalView model: @model
    else
      utils.redirectTo url: '/#wb-shipping-order-history'
