View = require 'views/base/view'
utils = require 'lib/utils'
$ = Winbits.$

module.exports = class LoginView extends View
  container: '#wbi-winbits-modals'
  id: 'wbi-coupons-modal'
  template: require './templates/coupons'

  initialize: ->
    super
    console.log ['Coupon model',@model]


  attach: ->
    super
    @showAsModal()

  showAsModal: ->
    $('<a>').wbfancybox(href: '#' + @id, onClosed: -> utils.redirectTo controller: 'home', action: 'index').click()
