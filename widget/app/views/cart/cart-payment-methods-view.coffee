View = require 'views/base/view'
$ = Winbits.$

module.exports = class CartPaymentMethodsView extends View
  container: '#wbi-cart-right-panel'
  template: require './templates/cart-payment-methods'
  id: 'wbi-cart-payment-methods'

  initialize: ->
    super

  attach: ->
    super
