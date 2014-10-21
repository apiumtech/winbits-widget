'use strict'
View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class CouponsView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-coupons-modal'
  template: require './templates/coupons'

  initialize: ->
    super
    @delegate 'click', '.wbc-download-pdf-link', @doCouponPdfLink
    @delegate 'click', '.wbc-download-html-link', @doCouponHtmlLink
    @delegate 'click', '#wbi-coupon-modal-btn', @doCloseCouponModal

  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo controller:'shipping-order-history',action:'index').click()

  doCouponPdfLink:(e)->
    currentTarget = @$(e.currentTarget).closest('.wbc-coupon-data')
    idCouponData = currentTarget.data('id')
    orderDetailId = currentTarget.data('order')
    @doRequestCouponService(idCouponData,orderDetailId,'pdf')

  doCouponHtmlLink:(e)->
    currentTarget = @$(e.currentTarget).closest('.wbc-coupon-data')
    idCouponData = currentTarget.data('id')
    orderDetailId = currentTarget.data('order')
    @doRequestCouponService(idCouponData,orderDetailId,'html')

  doRequestCouponService: (idCouponData, orderDetailId,format)->
    @popUp = window.open()
    @model.doRequestCouponService(idCouponData,orderDetailId,format, context:@)
     .done(@doRequestCouponServiceSuccess)
     .fail(-> @popUp.close())

  doRequestCouponServiceSuccess:(data)->
    @popUp.window?.location.href =(data.response.coupon.url)

  doCloseCouponModal: ->
    utils.closeMessageModal()
#    utils.redirectTo controller:'shipping-order-history',action:'index'