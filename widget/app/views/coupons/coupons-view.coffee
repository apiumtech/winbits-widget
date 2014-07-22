View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class LoginView extends View
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
    format = 'pdf'
    console.log ["Coupon Data", idCouponData, format]
    @doRequestCouponService(idCouponData,format)

  doCouponHtmlLink:(e)->
    idCouponData = @$(e.currentTarget).closest('.wbc-coupon-data').data('id')
    format = 'html'
    console.log ["Coupon Data", idCouponData, format]
    @doRequestCouponService(idCouponData,format)

  doRequestCouponService: (idCouponData, format)->
    @model.doRequestCouponService(idCouponData,format)
     .done((data)-> console.log ["Data coupon", data])
     .fail((xhr)-> console.log ["Data coupon error", xhr.responseText])