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

  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo url: '/#wb-shipping-order-history').click()

  doCouponPdfLink:(e)->
    idCouponData = @$(e.currentTarget).closest('.wbc-coupon-data').data('id')
    @doRequestCouponService(idCouponData,'pdf')

  doCouponHtmlLink:(e)->
    idCouponData = @$(e.currentTarget).closest('.wbc-coupon-data').data('id')
    @doRequestCouponService(idCouponData,'html')

  doRequestCouponService: (idCouponData, format)->
    @popUp = window.open()
    @model.doRequestCouponService(idCouponData,format, context:@)
     .done(@doRequestCouponServiceSuccess)
     .fail(-> @popUp.close())

  doRequestCouponServiceSuccess:(data)->
    @popUp.window?.location.href =(data.response.coupon.url)