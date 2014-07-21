View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-coupons-modal'
  template: require './templates/coupons'

  initialize: ->
    super
    @delegate 'click', '.wbc-download-pdf-link', @doRequestCouponLink


  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo url: '/#wb-shipping-order-history').click()

  doRequestCouponLink:(e)->
    idCouponData = @$(e.currentTarget).closest('.wbc-coupon-data').data('id')
    console.log ["Coupon Data", idCouponData]